local data = require('wowapi.data')
local util = require('wowless.util')

local function loadApis(product)
  return require('build.products.' .. product .. '.data').apis
end

local function loadSqls(loader, apis)
  local datalua = require('build.products.' .. loader.product .. '.data')
  local function lookup(stmt)
    for row in stmt:rows() do -- luacheck: ignore 512
      return unpack(row)
    end
  end
  local function cursor(stmt)
    return stmt:urows()
  end
  local sqlite = loader.sqlitedb
  local function prep(fn, sql, f)
    local stmt = sqlite:prepare(sql)
    if not stmt then
      error('could not prepare ' .. fn .. ': ' .. sqlite:errmsg())
    end
    return function(...)
      stmt:reset()
      stmt:bind_values(...)
      return f(stmt)
    end
  end
  local lookups = {}
  local cursors = {}
  for n, api in pairs(apis) do
    for _, sql in ipairs(api.sqls or {}) do
      if sql.lookup then
        local sn = sql.lookup
        lookups[sn] = lookups[sn] or prep(sn, datalua.sqllookups[sn], lookup)
      elseif sql.cursor then
        local sn = sql.cursor
        cursors[sn] = cursors[sn] or prep(sn, datalua.sqlcursors[sn], cursor)
      else
        error('invalid sql spec for ' .. n)
      end
    end
  end
  return {
    cursors = cursors,
    lookups = lookups,
  }
end

local function mkdb2s(loader)
  return setmetatable({}, {
    __index = function(dbs, db)
      local t = {}
      for row in loader.db2rows(db) do
        table.insert(t, row)
      end
      dbs[db] = {
        data = t,
        indices = {},
      }
      return dbs[db]
    end,
  })
end

local function doGetFn(api, loader, apicfg, impls, db2s, sqls)
  if apicfg.status == 'autogenerated' or apicfg.status == 'unimplemented' then
    return setfenv(assert(loadstring(apicfg.stub)), api.env)
  elseif apicfg.status == 'implemented' then
    local args = {}
    local frameworks = {
      api = api, -- TODO replace api framework with something finer grained
      env = api.env,
      loader = loader,
    }
    for _, fw in ipairs(apicfg.frameworks or {}) do
      table.insert(args, (assert(frameworks[fw], 'unknown framework ' .. fw)))
    end
    for _, st in ipairs(apicfg.states or {}) do
      table.insert(args, api.states[st])
    end
    for _, db in ipairs(apicfg.dbs or {}) do
      table.insert(
        args,
        (function()
          if not db.index then
            return function()
              local t = db2s[db.name].data
              local idx = 0
              return function()
                idx = idx + 1
                return t[idx]
              end
            end
          else
            local function keyify(x)
              return type(x) == 'string' and x:lower() or x
            end
            return function(k)
              local db2 = db2s[db.name]
              local index = db2.indices[db.index]
              if not index then
                index = {}
                for _, row in ipairs(db2.data) do
                  local rowkey = keyify(row[db.index])
                  index[rowkey] = index[rowkey] or row
                end
                db2.indices[db.index] = index
              end
              return index[keyify(k)]
            end
          end
        end)()
      )
    end
    for _, sql in ipairs(apicfg.sqls or {}) do
      table.insert(args, sql.lookup and sqls.lookups[sql.lookup] or sqls.cursors[sql.cursor])
    end
    local impl = impls[apicfg.name]
    return function(...)
      local t = {}
      for _, v in ipairs(args) do
        table.insert(t, v)
      end
      local n = select('#', ...)
      for i = 1, n do
        local v = select(i, ...)
        if i then
          t[#args + i] = v
        end
      end
      return impl(unpack(t, 1, #args + n))
    end
  else
    error(('invalid status %q on %q'):format(apicfg.status, apicfg.name))
  end
end

local function getFn(api, loader, apicfg, impls, db2s, sqls)
  local stub = doGetFn(api, loader, apicfg, impls, db2s, sqls)
  return apicfg.outputs == nil and stub
    or function(...)
      return (function(...)
        for idx, out in ipairs(apicfg.outputs) do
          if out.mixin then
            local t = select(idx, ...)
            if t then
              api.env.Mixin(t, api.env[out.mixin])
            end
          end
        end
        return ...
      end)(stub(...))
    end
end

local function resolveUnit(units, unit)
  -- TODO complete unit resolution
  local guid = units.aliases[unit:lower()]
  return guid and units.guids[guid] or nil
end

local function loadFunctions(api, loader)
  api.log(1, 'loading functions')
  local fns = {}
  local apis = loadApis(loader.product)
  local sqls = loadSqls(loader, apis)
  local db2s = mkdb2s(loader)
  local impls = {}
  for k, v in pairs(require('build.products.' .. loader.product .. '.data').impls) do
    impls[k] = loadstring(v)
  end
  local aliases = {}
  for fn, apicfg in pairs(apis) do
    if apicfg.alias then
      aliases[fn] = apicfg.alias
    elseif apicfg.stdlib then
      util.tset(fns, fn, util.tget(_G, apicfg.stdlib))
    else
      local bfn = getFn(api, loader, apicfg, impls, db2s, sqls)
      local function doCheckInputs(sig, ...)
        local args = {}
        for i, param in ipairs(sig) do
          local arg = select(i, ...)
          if arg == nil then
            if not param.nilable and param.default == nil then
              error(('arg %d (%q) of %q is not nilable, but nil was passed'):format(i, tostring(param.name), fn))
            end
          else
            local ty = type(arg)
            -- Simulate C lua_tonumber and lua_tostring.
            if param.type == 'number' and ty == 'string' then
              arg = tonumber(arg) or arg
              ty = type(arg)
            elseif param.type == 'string' and ty == 'number' then
              arg = tostring(arg) or arg
              ty = type(arg)
            elseif param.type == 'unknown' or data.structures[param.type] ~= nil then
              ty = param.type
            elseif param.type == 'unit' and ty == 'string' then
              arg = resolveUnit(api.states.Units, arg)
              ty = 'unit'
            end
            if ty ~= param.type then
              error(
                ('arg %d (%q) of %q is of type %q, but %q was passed'):format(
                  i,
                  tostring(param.name),
                  fn,
                  param.type,
                  ty
                )
              )
            end
            args[i] = arg
          end
        end
        return unpack(args, 1, select('#', ...))
      end
      local checkInputs = (function()
        if not apicfg.inputs then
          return function(...)
            return ...
          end
        elseif #apicfg.inputs == 1 then
          return function(...)
            return doCheckInputs(apicfg.inputs[1], ...)
          end
        else
          return function(...)
            local t = { ... }
            local n = select('#', ...)
            for _, sig in ipairs(apicfg.inputs) do
              local result = {
                pcall(function()
                  return doCheckInputs(sig, unpack(t, 1, n))
                end),
              }
              if result[1] then
                return unpack(result, 2)
              end
            end
            error('args matched no input signature of ' .. fn)
          end
        end
      end)()
      local checkOutputs = (function()
        if not apicfg.outputs then
          return function(...)
            return ...
          end
        else
          local nilableTypes = {
            ['nil'] = true,
            oneornil = true,
            unknown = true,
          }
          local supportedTypes = {
            boolean = true,
            number = true,
            string = true,
          }
          return function(...)
            for i, out in ipairs(apicfg.outputs) do
              local arg = select(i, ...)
              if arg == nil then
                if not out.nilable and not nilableTypes[out.type] then
                  error(('output %d (%q) of %q is not nilable, but nil was returned'):format(i, tostring(out.name), fn))
                end
              elseif supportedTypes[out.type] then
                local ty = type(arg)
                if ty ~= out.type then
                  error(
                    ('output %d (%q) of %q is of type %q, but %q was returned'):format(
                      i,
                      tostring(out.name),
                      fn,
                      out.type,
                      ty
                    )
                  )
                end
              end
            end
            return ...
          end
        end
      end)()
      local function thefunc(...)
        return checkOutputs(bfn(checkInputs(...)))
      end
      if not apicfg.nowrap then
        thefunc = debug.newcfunction(thefunc)
      end
      util.tset(fns, fn, thefunc)
    end
  end
  for k, v in pairs(aliases) do
    fns[k] = util.tget(fns, v)
  end
  api.log(1, 'functions loaded')
  return fns
end

return {
  loadFunctions = loadFunctions,
}

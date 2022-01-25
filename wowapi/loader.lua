local data = require('wowapi.data')
local plprettywrite = require('pl.pretty').write

local function loadApis(version)
  local apis = {}
  for fn, yaml in pairs(data.apis) do
    local match = not yaml.versions
    if yaml.versions then
      for _, v in ipairs(yaml.versions) do
        if version == v then
          match = true
        end
      end
    end
    if match then
      apis[fn] = yaml
    end
  end
  return apis
end

local getStub = (function()
  local defaultOutputs = {
    bool = 'false',
    ['nil'] = 'nil',
    number = '1',
    oneornil = 'nil',
    string = '\'\'',
    table = '{}',
    unknown = 'nil',
  }
  local structureDefaults = {}
  local function ensureStructureDefault(name)
    if structureDefaults[name] == nil then
      structureDefaults[name] = true
      local st = data.structures[name]
      local t = {}
      for _, field in ipairs(st.fields) do
        local v
        if data.structures[field.type] then
          ensureStructureDefault(field.type)
          v = structureDefaults[field.type]
        else
          v = tostring(defaultOutputs[field.nilable and 'nil' or field.type])
        end
        table.insert(t, ('[%q]=%s'):format(field.name, v))
      end
      structureDefaults[name] = '{' .. table.concat(t, ',') .. '}'
    else
      assert(structureDefaults[name] ~= true, 'loop in structure definitions')
    end
  end
  for name in pairs(data.structures) do
    ensureStructureDefault(name)
  end
  return function(sig)
    local rets = {}
    for _, out in ipairs(sig) do
      local v
      if out.stub or out.default then
        local value = out.stub or out.default
        local ty = type(value)
        if ty == 'number' or ty == 'boolean' then
          v = tostring(value)
        elseif ty == 'string' then
          v = string.format('%q', value)
        elseif ty == 'table' then
          v = plprettywrite(value)
        else
          error('unsupported stub value type ' .. ty)
        end
      elseif out.nilable then
        v = 'nil'
      else
        v = defaultOutputs[out.type] or structureDefaults[out.type]
      end
      assert(v, ('invalid output type %q'):format(out.type))
      table.insert(rets, v)
    end
    return loadstring('return ' .. table.concat(rets, ', '))
  end
end)()

-- TODO rationalize this with wowless loader, multiple instances, etc
local function db2rows(env, name)
  local dbd = require('luadbd').dbds[name]
  local v, b = env.GetBuildInfo()
  local version = v .. '.' .. b
  local build = assert(dbd:build(version), ('cannot load %s in %s'):format(name, version))
  local db2 = require('path').join('extracts', version, 'db2', name .. '.db2')
  return build:rows(require('pl.file').read(db2))
end

local function doGetFn(api, loader, apicfg)
  if apicfg.status == 'autogenerated' or apicfg.status == 'unimplemented' then
    return getStub(apicfg.outputs or {})
  elseif apicfg.status == 'implemented' then
    local args = {}
    local frameworks = {
      api = api,  -- TODO replace api framework with something finer grained
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
      table.insert(args, function() return db2rows(api.env, db) end)
    end
    local impl = data.impl[apicfg.name]
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

local function getFn(api, loader, apicfg)
  local stub = doGetFn(api, loader, apicfg)
  return apicfg.outputs == nil and stub or function(...)
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
  local fns = {}
  for fn, apicfg in pairs(loadApis(loader.version)) do
    local bfn = getFn(api, loader, apicfg)
    local impl = (function()
      if apicfg.inputs then
        local function check(sig, ...)
          local args = {}
          for i, param in ipairs(sig) do
            local arg = select(i, ...)
            if arg == nil then
              assert(
                param.nilable or param.default ~= nil,
                ('arg %d (%q) of %q is not nilable, but nil was passed'):format(
                  i, tostring(param.name), fn))
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
              elseif ty == 'boolean' then
                ty = 'bool'
              elseif param.type == 'unit' and ty == 'string' then
                arg = resolveUnit(api.states.Units, arg)
                ty = 'unit'
              end
              assert(
                ty == param.type,
                ('arg %d (%q) of %q is of type %q, but %q was passed'):format(
                  i, tostring(param.name), fn, param.type, ty))
              args[i] = arg
            end
          end
          return unpack(args, 1, select('#', ...))
        end
        return function(...)
          if #apicfg.inputs == 1 then
            return bfn(check(apicfg.inputs[1], ...))
          else
            local t = {...}
            local n = select('#', ...)
            for _, sig in ipairs(apicfg.inputs) do
              local result = {pcall(function() return check(sig, unpack(t, 1, n)) end)}
              if result[1] then
                return bfn(unpack(result, 2))
              end
            end
            error('args matched no input signature of ' .. fn)
          end
        end
      end
      return bfn
    end)()
    local function wrapimpl(...)
      api.log(4, 'entering %s', apicfg.name)
      local t = {...}
      local n = select('#', ...)
      return (function(success, ...)
        api.log(4, 'leaving %s (%s)', apicfg.name, success and 'success' or 'failure')
        assert(success, ...)
        return ...
      end)(pcall(function() return impl(unpack(t, 1, n)) end))
    end
    local dot = fn:find('%.')
    if dot then
      local p = fn:sub(1, dot-1)
      fns[p] = fns[p] or {}
      fns[p][fn:sub(dot+1)] = wrapimpl
    else
      fns[fn] = wrapimpl
    end
  end
  return fns
end

return {
  loadFunctions = loadFunctions,
}

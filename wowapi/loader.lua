local data = require('wowapi.data')
local yamlnull = require('lyaml').null

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
  for name, st in pairs(data.structures) do
    structureDefaults[name] = (function()
      local t = {}
      for _, field in ipairs(st.fields) do
        local v = tostring(defaultOutputs[field.nilable and 'nil' or field.type])
        table.insert(t, ('[%q]=%s'):format(field.name, v))
      end
      return '{' .. table.concat(t, ',') .. '}'
    end)()
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

local function unpackReturns(r)
  local ret = {}
  for i, v in ipairs(r) do
    ret[i] = v ~= yamlnull and v or nil
  end
  return unpack(ret, 1, #r)
end

-- TODO rationalize this with wowless loader, multiple instances, etc
local function db2rows(env, name)
  local dbd = require('luadbd').dbds[name]
  local v, b = env.GetBuildInfo()
  local version = v .. '.' .. b
  local db2 = require('path').join('extracts', version, 'db2', name .. '.db2')
  return dbd:rows(version, require('pl.file').read(db2))
end

local function doGetFn(api, env, states)
  if api.status == 'autogenerated' or api.status == 'unimplemented' then
    return getStub(api.outputs or {})
  elseif api.status == 'stub' then
    return function() return unpackReturns(api.returns) end
  elseif api.status == 'implemented' then
    local args = {}
    for _, st in ipairs(api.states or {}) do
      table.insert(args, st == 'env' and env or states[st])
    end
    for _, db in ipairs(api.dbs or {}) do
      table.insert(args, function() return db2rows(env, db) end)
    end
    local impl = data.impl[api.name]
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
    error(('invalid status %q on %q'):format(api.status, api.name))
  end
end

local function getFn(api, env, states)
  local stub = doGetFn(api, env, states)
  return api.outputs == nil and stub or function(...)
    return (function(...)
      for idx, out in ipairs(api.outputs) do
        if out.mixin then
          local t = select(idx, ...)
          if t then
            env.Mixin(t, env[out.mixin])
          end
        end
      end
      return ...
    end)(stub(...))
  end
end

local function loadFunctions(version, env, log, states)
  local fns = {}
  for fn, api in pairs(loadApis(version)) do
    local bfn = getFn(api, env, states)
    local impl = (function()
      if api.inputs then
        local function check(sig, ...)
          for i, param in ipairs(sig) do
            local arg = select(i, ...)
            if arg == nil then
              assert(
                param.nilable or param.default ~= nil,
                ('arg %d (%q) of %q is not nilable, but nil was passed'):format(
                  i, tostring(param.name), fn))
            else
              local ty = type(arg)
              local nty = ty == 'boolean' and 'bool' or ty
              assert(
                nty == param.type,
                ('arg %d (%q) of %q is of type %q, but %q was passed'):format(
                  i, tostring(param.name), fn, param.type, nty))
            end
          end
        end
        return function(...)
          if #api.inputs == 1 then
            check(api.inputs[1], ...)
            return bfn(...)
          else
            local t = {...}
            local n = select('#', ...)
            for _, sig in ipairs(api.inputs) do
              if pcall(function() check(sig, unpack(t, 1, n)) end) then
                return bfn(...)
              end
            end
            error('args matched no input signature of ' .. fn)
          end
        end
      end
      return bfn
    end)()
    local function wrapimpl(...)
      log(4, 'entering %s', api.name)
      local t = {...}
      local n = select('#', ...)
      return (function(success, ...)
        log(4, 'leaving %s (%s)', api.name, success and 'success' or 'failure')
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
  getFn = getFn,
  loadApis = loadApis,
  loadFunctions = loadFunctions,
}

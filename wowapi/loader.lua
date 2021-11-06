local yaml = require('wowapi.yaml')
local yamlnull = require('lyaml').null

local function mixin(b, t)
  b = b or {}
  for k, v in pairs(t) do
    b[k] = v
  end
  return b
end

local loadApis = (function()
  local env = {
    require = require,
  }
  return function(dir, version)
    local apis = {}
    for f in require('lfs').dir(dir) do
      if f:sub(-4) == '.lua' then
        local fn = f:sub(1, -5)
        local api = setfenv(loadfile(dir .. '/' .. f), env)()
        apis[fn] = mixin(apis[fn], api)
      elseif f:sub(-5) == '.yaml' then
        local fn = f:sub(1, -6)
        local api = yaml.parseFile(dir .. '/' .. f)
        local match = not api.versions
        if api.versions then
          for _, v in ipairs(api.versions) do
            if version == v then
              match = true
            end
          end
        end
        if match then
          apis[fn] = mixin(apis[fn], api)
        end
      end
    end
    return apis
  end
end)()

local getStub = (function()
  local defaultOutputs = {
    b = 'false',
    n = '1',
    s = '\'\'',
    t = '{}',
    x = 'nil',
    z = 'nil',
    ['?'] = 'nil',
  }
  local function mkStub(sig)
    local rets = {}
    for i = 1, string.len(sig) do
      local v = defaultOutputs[sig:sub(i, i)]
      assert(v, ('invalid output signature %q'):format(sig))
      table.insert(rets, v)
    end
    return loadstring('return ' .. table.concat(rets, ', '))
  end
  local stubs = {}
  return function(sig)
    local stub = stubs[sig]
    if not stub then
      stub = mkStub(sig)
      stubs[sig] = stub
    end
    return stub
  end
end)()

local argSig = (function()
  local typeSigs = {
    boolean = 'b',
    ['function'] = 'f',
    ['nil'] = 'x',
    number = 'n',
    string = 's',
    table = 't',
    userdata = 'u',
  }
  return function(fn, ...)
    -- Ignore trailing nils for our purposes.
    local last = select('#', ...)
    while last > 0 and (select(last, ...)) == nil do
      last = last - 1
    end
    local sig = ''
    for i = 1, last do
      local ty = type((select(i, ...)))
      local c = typeSigs[ty]
      if not c then
        error(('invalid argument %d of type %q to %q'):format(i, ty, fn))
      end
      sig = sig .. c
    end
    return sig
  end
end)()

local function checkSig(fn, apisigs, fsig)
  for _, x in ipairs(apisigs) do
    if fsig == x then
      return
    end
  end
  error(('invalid arguments to %q, expected one of {%s}, got %q'):format(fn, table.concat(apisigs, ', '), fsig))
end

local function unpackReturns(r)
  local ret = {}
  for i, v in ipairs(r) do
    ret[i] = v ~= yamlnull and v or nil
  end
  return unpack(ret, 1, #r)
end

local function getFn(api, modules, env)
  if api.status == 'autogenerated' or api.status == 'unimplemented' then
    assert(api.impl == nil, ('%q should not have an explicit implementation'):format(api.name))
    if api.mixin then
      assert(api.outputs == 't', 'mixin only works with outputs=t')
      return function() env.Mixin({}, env[api.mixin]) end
    else
      return getStub(api.outputs or '')
    end
  elseif api.status == 'stub' then
    return assert(api.impl or api.returns and function() return unpackReturns(api.returns) end)
  elseif api.status == 'implemented' then
    return assert(modules[api.module].api[api.api])
  else
    error(('invalid status %q on %q'):format(api.status, api.name))
  end
end

local function loadFunctions(dir, version, env)
  local mods = {}
  for filename in require('lfs').dir(dir .. '/../modules') do
    if filename:sub(-4) == '.lua' then
      mods[filename:sub(1, -5)] = loadfile(dir .. '/../modules/' .. filename)(env)
    end
  end
  local fns = {}
  for fn, api in pairs(loadApis(dir, version)) do
    local bfn = getFn(api, mods, env)
    local impl = (function()
      if api.inputs == nil then
        return bfn
      end
      local inputs = api.inputs
      if type(inputs) == 'string' then
        inputs = {inputs}
      end
      if type(inputs) ~= 'table' then
        error(('invalid inputs type on %q'):format(fn))
      end
      return function(...)
        checkSig(fn, inputs, argSig(fn, ...))
        return bfn(...)
      end
    end)()
    local dot = fn:find('%.')
    if dot then
      local p = fn:sub(1, dot-1)
      fns[p] = fns[p] or {}
      fns[p][fn:sub(dot+1)] = impl
    else
      fns[fn] = impl
    end
  end
  return fns
end

return {
  argSig = argSig,
  getFn = getFn,
  loadApis = loadApis,
  loadFunctions = loadFunctions,
}

local product, filename = unpack(arg)

local data
do
  local env = {}
  setfenv(loadfile(filename), env)()
  data = env.WowlessLastTestFailures
end

local yaml = require('wowapi.yaml')
local write = require('pl.file').write

local getPatternValue = (function()
  local function constant(x)
    return function()
      return x
    end
  end
  local function mustnumber(x)
    return assert(tonumber(x))
  end
  local patterns = {
    {
      pattern = ': want %d+, got (%d+)$',
      value = mustnumber,
    },
    {
      pattern = ': want ".+", got "nil"$',
      value = constant(nil),
    },
    {
      pattern = ': missing, has value (%d+)$',
      value = mustnumber,
    },
    {
      pattern = ': missing key ".+" with value (%d+)$',
      value = mustnumber,
    },
    {
      pattern = ': missing key ".+" with value table: 0x[0-9a-f]+$',
      value = constant({}),
    },
  }

  local function forwardValue(a1, ...)
    assert(select('#', ...) == 0)
    return a1
  end

  local function forwardMatch(fn, a1, ...)
    if a1 then
      return true, forwardValue(fn(a1, ...))
    end
  end

  return function(v)
    for _, p in ipairs(patterns) do
      local match, value = forwardMatch(p.value, v:match(p.pattern))
      if match then
        return true, value
      end
    end
    print(('warning: no pattern matched %q'):format(v))
  end
end)()

local function applyPatterns(tx, ty)
  for k, v in pairs(ty) do
    if type(v) == 'table' then
      applyPatterns(tx[k], v)
    else
      local match, value = getPatternValue(v)
      if match then
        tx[k] = value
      end
    end
  end
end

do
  local gf = 'data/globals/' .. product .. '.yaml'
  local g = yaml.parseFile(gf)
  applyPatterns(g, data.generated.globals)
  write(gf, yaml.pprint(g))
end

local allProducts = require('wowless.util').productList()

local function addProduct(products)
  local newproducts = {}
  local match = false
  for _, p in ipairs(products or {}) do
    table.insert(newproducts, p)
    match = match or p == product
  end
  if not match then
    table.insert(newproducts, product)
  end
  if #newproducts == #allProducts then
    return nil
  else
    table.sort(newproducts)
    return newproducts
  end
end

local function removeProduct(products)
  local newproducts = {}
  for _, p in ipairs(products or allProducts) do
    if p ~= product then
      table.insert(newproducts, p)
    end
  end
  return newproducts
end

for k, v in pairs(data.generated.globalApis or {}) do
  if k:sub(1, 1) ~= '~' then
    local apifile = 'data/api/' .. k .. '.yaml'
    local api = yaml.parseFile(apifile)
    if type(v) == 'string' then
      assert(v:match(': want "function", got "nil"$'))
      api.products = removeProduct(api.products)
    elseif type(v) == 'table' then
      assert(next(v) == 'impltype')
      assert(next(v, 'impltype') == nil)
      assert(v.impltype:match(': bad argument #1 to \'create\' %(Lua function expected%): want true, got false$'), k)
      api.products = addProduct(api.products)
    else
      error('invalid type at globalApi ' .. k)
    end
    write(apifile, yaml.pprint(api))
  end
end

for k, v in pairs(data.generated.uiobjects or {}) do
  if v.methods then
    local uf = 'data/uiobjects/' .. k .. '/' .. k .. '.yaml'
    local u = yaml.parseFile(uf)
    for mk, mv in pairs(v.methods) do
      if mv:match(': missing$') or mv:match(': product disabled: want "nil", got "function"') then
        local m = u.methods[mk]
        if not m then
          m = { products = {}, status = 'unimplemented' }
          u.methods[mk] = m
        end
        m.products = addProduct(m.products)
      end
    end
    write(uf, yaml.pprint(u))
  end
end

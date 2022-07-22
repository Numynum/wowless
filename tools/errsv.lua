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
        assert(m.products)
        local match = false
        for _, p in ipairs(m.products) do
          match = match or p == product
        end
        if not match then
          table.insert(m.products, product)
        end
        table.sort(m.products)
      end
    end
    write(uf, yaml.pprint(u))
  end
end
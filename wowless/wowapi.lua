local UNIMPLEMENTED = function() end
local STUB_NUMBER = function() return 1 end
local STUB_TABLE = function() return {} end
local function getFn(t)
  if t.status == 'unimplemented' then
    return UNIMPLEMENTED
  elseif t.status == 'stubnumber' then
    return STUB_NUMBER
  elseif t.status == 'stubtable' then
    return STUB_TABLE
  else
    return assert(t.impl)
  end
end
local fns = {}
for f in require('lfs').dir('wowapi') do
  if f:sub(-4) == '.lua' then
    local fn = f:sub(1, -5)
    local t = dofile('wowapi/' .. f)
    assert(fn == t.name, ('invalid name %q in %q'):format(t.name, f))
    local dot = fn:find('%.')
    if dot then
      local p = fn:sub(1, dot-1)
      fns[p] = fns[p] or {}
      fns[p][fn:sub(dot+1)] = getFn(t)
    else
      fns[fn] = getFn(t)
    end
  end
end
return fns

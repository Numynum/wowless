return (function(self)
  local ret = {}
  for kid in u(self).children:entries() do
    if kid:IsObjectType('frame') then
      table.insert(ret, kid.luarep)
    end
  end
  return unpack(ret)
end)(...)

local units, sql, tabIndex, talentIndex = ...
local num = 0
local t = {}
for tier, column in sql(units.guids[units.aliases.player].class, tabIndex, talentIndex) do
  t[num + 1] = tier
  t[num + 2] = column
  num = num + 3
end
return unpack(t, 1, num)

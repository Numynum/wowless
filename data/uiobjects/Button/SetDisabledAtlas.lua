return (function(self, atlas)
  local ud = u(self)
  ud.disabledTexture = ud.disabledTexture or self:CreateTexture()
  ud.disabledTexture:SetAtlas(atlas)
end)(...)

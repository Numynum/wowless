local function run(loglevel, version)
  local function log(level, fmt, ...)
    if level <= loglevel then
      print(string.format(fmt, ...))
    end
  end
  local api = require('wowless.api').new(log)
  require('wowless.env').init(api)
  local loader = require('wowless.loader')
  local rootDirs = {
    wow = loader.wowRetailRootDir,
    wowt = loader.wowRetailPtrRootDir,
    wow_classic = loader.wowClassicRootDir,
    wow_classic_era = loader.wowClassicEraRootDir,
    wow_classic_ptr = loader.wowClassicPtrRootDir,
  }
  loader.loader(api).loadFrameXml(assert(rootDirs[version]))
  api.SendEvent('PLAYER_LOGIN')
  api.SendEvent('UPDATE_CHAT_WINDOWS')
  api.SendEvent('PLAYER_ENTERING_WORLD')
  for _, frame in ipairs(api.frames) do
    if frame.Click and frame:IsVisible() then
      frame:Click()
    end
  end
  api.NextFrame()
  api.SendEvent('PLAYER_REGEN_DISABLED')
  api.NextFrame()
  api.SendEvent('PLAYER_REGEN_ENABLED')
  api.NextFrame()
  for _, frame in ipairs(api.frames) do
    if frame:IsVisible() then
      api.RunScript(frame, 'OnEnter', true)
      api.RunScript(frame, 'OnLeave', true)
    end
  end
  api.SendEvent('PLAYER_LOGOUT')
  return api
end

return {
  run = run,
}

local function defs(product)
  local build = require('wowapi.yaml').parseFile('data/products/' .. product .. '/build.yaml')
  local bv = build.version .. '.' .. build.build
  local t = {}
  for _, db in ipairs(require('build.products.' .. product .. '.dblist')) do
    local content = assert(require('pl.file').read('vendor/dbdefs/definitions/' .. db .. '.dbd'))
    local dbd = assert(require('luadbd.parser').dbd(content))
    local v = (function()
      for _, version in ipairs(dbd.versions) do
        for _, vb in ipairs(version.builds) do
          -- Build ranges are not supported (yet).
          if #vb == 1 and table.concat(vb[1], '.') == bv then
            return version
          end
        end
      end
      error('cannot find ' .. bv .. ' in dbd ' .. db)
    end)()
    local sig, field2index = require('luadbd.sig')(dbd, v)
    t[db] = {
      field2index = field2index,
      sig = sig,
    }
  end
  return t
end

local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to process')
  return parser:parse()
end)()

local deps = {}
for _, db in ipairs(require('build.products.' .. args.product .. '.dblist')) do
  deps['vendor/dbdefs/definitions/' .. db .. '.dbd'] = true
end

local outfile = 'build/products/' .. args.product .. '/dbdefs.lua'
local u = require('tools.util')
u.writedeps(outfile, deps)
u.writeifchanged(outfile, u.returntable(defs(args.product)))

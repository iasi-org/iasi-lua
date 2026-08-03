local Cache = {}
function Cache.open(options)
  local fs=assert(options.filesystem); local dir=assert(options.directory); local ext=assert(options.extension); local mode=options.mode
  fs.ensure_directory(dir)
  if mode == "clean" then fs.clean_directory(dir); mode=true end
  local c={}
  local function paths(d) return {resource=pandoc.path.join({dir,d.."."..ext}), marker=pandoc.path.join({dir,d..".sha1"})} end
  function c.get(d)
    if mode ~= true then return nil end
    local p=paths(d)
    if not fs.exists(p.resource) or not fs.exists(p.marker) then return nil end
    local stored=fs.read(p.marker):gsub("%s+$","")
    if stored ~= d then return nil end
    return fs.read(p.resource)
  end
  function c.put(d,contents) if mode ~= true then return end; local p=paths(d); fs.write(p.resource,contents); fs.write(p.marker,d.."\n") end
  return c
end
return Cache

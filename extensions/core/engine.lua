local Engine = {}
local function has_class(block, expected) for _,c in ipairs(block.classes) do if c==expected then return true end end return false end
local function merge(global, block, Config)
  local r={}
  for k,v in pairs(global) do r[k]=v end
  for _,k in ipairs({"server","format","cache"}) do if block.attributes[k]~=nil then r[k]=block.attributes[k] end end
  r.cache=Config.normalize_cache(r.cache)
  return r
end
function Engine.create(spec)
  local core_dir=assert(spec.core_dir,"Falta specification.core_dir")
  local function load(name) return dofile(pandoc.path.join({core_dir,name..".lua"})) end
  local Metadata=load("metadata"); local Config=load("config"); local Filesystem=load("filesystem"); local Cache=load("cache"); local MediaBag=load("mediabag")
  local name=assert(spec.name); local compiler=assert(spec.compiler); local defaults=assert(spec.defaults); local block_class=spec.block_class or name; local version=spec.version or "0.0.0"
  local function Pandoc(document)
    local config=Config.load(document.meta,name,defaults,Metadata)
    if config.enabled==false then return document end
    local cache=Cache.open({filesystem=Filesystem,directory=pandoc.path.join({".quarto",name}),extension=tostring(config.format),mode=config.cache})
    local function CodeBlock(block)
      if not has_class(block,block_class) then return nil end
      local cfg=merge(config,block,Config); local source=block.text
      if compiler.prepare~=nil then source=compiler.prepare(source,cfg) end
      local digest=pandoc.utils.sha1(table.concat({source,tostring(cfg.server or ""),tostring(cfg.format or ""),tostring(version)},"\n"))
      local contents=nil; local mime=nil
      if cfg.cache==true then contents=cache.get(digest) end
      if contents==nil then mime,contents=compiler.compile(source,cfg); if cfg.cache==true then cache.put(digest,contents) end else mime=compiler.mime_type(cfg) end
      local media_path=name.."/"..digest.."."..tostring(cfg.format)
      return MediaBag.publish(block,media_path,mime,contents)
    end
    return document:walk({CodeBlock=CodeBlock})
  end
  return {{Pandoc=Pandoc}}
end
return Engine

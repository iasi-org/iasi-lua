local MediaBag = {}
local function caption_to_inlines(text)
  if text==nil or text=="" then return pandoc.Inlines({}) end
  local doc=pandoc.read(text,"markdown"); local r=pandoc.Inlines({})
  for _,b in ipairs(doc.blocks) do if b.t=="Para" or b.t=="Plain" then if #r>0 then r:insert(pandoc.Space()) end; r:extend(b.content) end end
  return r
end
local function attrs(block)
  local r={}
  for k,v in pairs(block.attributes) do if k~="server" and k~="format" and k~="cache" and k~="fig-cap" and k~="caption" and k~="label" then r[k]=v end end
  return r
end
function MediaBag.publish(block,path,mime,contents)
  pandoc.mediabag.insert(path,mime,contents)
  local caption=caption_to_inlines(block.attributes["fig-cap"] or block.attributes["caption"] or "")
  local id=block.identifier; if id==nil or id=="" then id=block.attributes["label"] or "" end
  return pandoc.Para({pandoc.Image(caption,path,"",pandoc.Attr(id,{},attrs(block)))})
end
return MediaBag

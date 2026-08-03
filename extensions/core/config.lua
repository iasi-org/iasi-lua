local Config = {}

local function clone(source)
  local target = {}
  for k,v in pairs(source or {}) do target[k]=v end
  return target
end

function Config.normalize_cache(value)
  if value == true or value == false then return value end
  local text = tostring(value):lower()
  if text == "true" then return true elseif text == "false" then return false elseif text == "clean" then return "clean" end
  error('Valor de cache no valido: '..tostring(value)..'. Use true, false o "clean".')
end

function Config.load(meta, filter_name, defaults, metadata)
  local result = clone(defaults)
  local options = meta["filter-options"]
  if options ~= nil and options[filter_name] ~= nil then
    for k,v in pairs(options[filter_name]) do result[k]=metadata.value(v,result[k]) end
  end
  result.enabled = metadata.boolean(result.enabled, true)
  result.cache = Config.normalize_cache(result.cache)
  return result
end

return Config

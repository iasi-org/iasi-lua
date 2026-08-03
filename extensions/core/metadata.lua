local Metadata = {}

function Metadata.value(value, default)
  if value == nil then return default end
  local t = pandoc.utils.type(value)
  if t == "Inlines" or t == "Blocks" then return pandoc.utils.stringify(value) end
  if t == "List" then
    local r = {}
    for _, item in ipairs(value) do table.insert(r, Metadata.value(item)) end
    return r
  end
  if type(value) == "table" then
    local r = {}
    for k, item in pairs(value) do r[k] = Metadata.value(item) end
    return r
  end
  return value
end

function Metadata.boolean(value, default)
  value = Metadata.value(value, default)
  if type(value) == "boolean" then return value end
  local text = tostring(value):lower()
  if text == "true" then return true elseif text == "false" then return false end
  return default
end

return Metadata

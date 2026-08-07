local function load_resource(path)
  return dofile(quarto.utils.resolve_path(path))
end

local function load_core(name)
  return load_resource("./core/" .. name .. ".lua")
end

local Engine = load_core("engine")
local Compiler = load_resource("./compiler.lua")
local Defaults = load_resource("./defaults.lua")
local Version = load_resource("./version.lua")

return Engine.create({
  name = "extension-name",
  version = Version,
  compiler = Compiler,
  defaults = Defaults,
  load_core = load_core
})

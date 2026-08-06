local test_directory = pandoc.path.directory(PANDOC_SCRIPT_FILE)
local repository = pandoc.path.normalize(
  pandoc.path.join({ test_directory, ".." })
)
local extension = pandoc.path.join({
  repository,
  "_extensions",
  "iasi-lua"
})

local function load_core(name)
  return dofile(
    pandoc.path.join({
      extension,
      "core",
      name .. ".lua"
    })
  )
end

local Engine = load_core("engine")
local Compiler = dofile(
  pandoc.path.join({
    extension,
    "plantuml",
    "compiler.lua"
  })
)
local Defaults = dofile(
  pandoc.path.join({
    extension,
    "plantuml",
    "defaults.lua"
  })
)

return Engine.create({
  name = "plantuml",
  block_class = "plantuml",
  version = "0.3.2",
  compiler = Compiler,
  defaults = Defaults,
  load_core = load_core
})

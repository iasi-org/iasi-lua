local test_directory = pandoc.path.directory(PANDOC_SCRIPT_FILE)
local extension = pandoc.path.normalize(
  pandoc.path.join({
    test_directory,
    "..",
    "..",
    "_extensions",
    "iasi-plantuml"
  })
)

-- Unit tests must not depend on the host curl executable or on a live
-- PlantUML server. The compiler still calls pandoc.pipe("curl", ...);
-- here we replace that boundary with a deterministic fake response.
local original_pipe = pandoc.pipe

pandoc.pipe = function(command, arguments, input)
  if command == "curl" then
    local status = os.getenv("FAKE_STATUS") or "200"

    return "\137PNG\r\n\26\nIASI-TEST"
      .. "\nIASI_PLANTUML_HTTP_STATUS:"
      .. status
  end

  return original_pipe(command, arguments, input)
end

local function load_core(name)
  return dofile(
    pandoc.path.join({ extension, "core", name .. ".lua" })
  )
end

local Engine = load_core("engine")
local Compiler = dofile(pandoc.path.join({ extension, "compiler.lua" }))
local Defaults = dofile(pandoc.path.join({ extension, "defaults.lua" }))
local Version = dofile(pandoc.path.join({ extension, "version.lua" }))

return Engine.create({
  name = "plantuml",
  block_class = "plantuml",
  version = Version,
  compiler = Compiler,
  defaults = Defaults,
  load_core = load_core,
  block_options = { "server", "format", "cache" },
  cache_keys = { "server", "format" }
})

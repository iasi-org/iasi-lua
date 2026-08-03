local Engine = {}

local function has_class(block, expected)
  for _, class_name in ipairs(block.classes) do
    if class_name == expected then
      return true
    end
  end

  return false
end

local function merge_block_config(global_config, block, config_module)
  local result = {}

  for key, value in pairs(global_config) do
    result[key] = value
  end

  for _, key in ipairs({ "server", "format", "cache" }) do
    if block.attributes[key] ~= nil then
      result[key] = block.attributes[key]
    end
  end

  result.cache = config_module.normalize_cache(result.cache)

  return result
end

function Engine.create(specification)
  local core_dir = assert(
    specification.core_dir,
    "Falta specification.core_dir"
  )

  local function load_core(name)
    return dofile(
      pandoc.path.join({
        core_dir,
        name .. ".lua"
      })
    )
  end

  local Metadata = load_core("metadata")
  local Config = load_core("config")
  local Filesystem = load_core("filesystem")
  local Cache = load_core("cache")
  local MediaBag = load_core("mediabag")

  local name = assert(
    specification.name,
    "Falta specification.name"
  )

  local compiler = assert(
    specification.compiler,
    "Falta specification.compiler"
  )

  local defaults = assert(
    specification.defaults,
    "Falta specification.defaults"
  )

  local block_class = specification.block_class or name
  local version = specification.version or "0.0.0"

  local function Pandoc(document)
    local config = Config.load(
      document.meta,
      name,
      defaults,
      Metadata
    )

    if config.enabled == false then
      return document
    end

    local cache = Cache.open({
      filesystem = Filesystem,
      directory = pandoc.path.join({
        ".quarto",
        name
      }),
      extension = tostring(config.format),
      mode = config.cache
    })

    local function CodeBlock(block)
      if not has_class(block, block_class) then
        return nil
      end

      local block_config = merge_block_config(
        config,
        block,
        Config
      )

      local source = block.text

      if compiler.prepare ~= nil then
        source = compiler.prepare(
          source,
          block_config
        )
      end

      local digest = pandoc.utils.sha1(
        table.concat({
          source,
          tostring(block_config.server or ""),
          tostring(block_config.format or ""),
          tostring(version)
        }, "\n")
      )

      local contents = nil
      local mime_type = nil

      if block_config.cache == true then
        contents = cache.get(digest)
      end

      if contents == nil then
        mime_type, contents = compiler.compile(
          source,
          block_config
        )

        if type(contents) ~= "string"
          or contents == ""
        then
          error(
            "El compilador '"
              .. name
              .. "' no devolvio contenido."
          )
        end

        if mime_type == nil or mime_type == "" then
          mime_type = compiler.mime_type(block_config)
        end

        if block_config.cache == true then
          cache.put(digest, contents)
        end
      else
        mime_type = compiler.mime_type(block_config)
      end

      local media_path = table.concat({
        name,
        "/",
        digest,
        ".",
        tostring(block_config.format)
      })

      return MediaBag.publish(
        block,
        media_path,
        mime_type,
        contents
      )
    end

    return document:walk({
      CodeBlock = CodeBlock
    })
  end

  return {
    {
      Pandoc = Pandoc
    }
  }
end

return Engine

local Compiler = {}

local MIME_TYPES = {
    png = "image/png",
    svg = "image/svg+xml"
}

local function trim_trailing_slash(value)
  return (value:gsub("/+$", ""))
end

local function read_file(path)
  local file, message = io.open(path, "rb")

  if file == nil then
    error(
      "No se pudo leer el archivo "
        .. tostring(path)
        .. ": "
        .. tostring(message)
    )
  end

  local contents = file:read("*a")
  file:close()

  return contents
end

local function normalize_styles(styles)
  if styles == nil then
    return {}
  end

  if type(styles) == "table" then
    return styles
  end

  return { tostring(styles) }
end

local function inject_after_startuml(source, style_source)
  if style_source == "" then
    return source
  end

  local _, end_position = source:find("@startuml[^\r\n]*")

  if end_position == nil then
    return style_source .. "\n" .. source
  end

  return source:sub(1, end_position)
    .. "\n"
    .. style_source
    .. "\n"
    .. source:sub(end_position + 1)
end

local function post_with_curl(url, source)
  local ok, result = pcall(
    pandoc.pipe,
    "curl",
    {
      "--fail",
      "--silent",
      "--show-error",
      "--request",
      "POST",
      "--header",
      "Content-Type: text/plain; charset=utf-8",
      "--data-binary",
      "@-",
      url
    },
    source
  )

  if not ok then
    error(
      "No se pudo ejecutar curl para invocar PlantUML.\n"
        .. "URL: "
        .. url
        .. "\nDetalle: "
        .. tostring(result)
        .. "\nCompruebe que curl está disponible en PATH."
    )
  end

  return result
end

function Compiler.prepare(source, config)
  local styles = normalize_styles(config.styles)

  if #styles == 0 then
    return source
  end

  local fragments = {}

  for _, path in ipairs(styles) do
    table.insert(fragments, read_file(tostring(path)))
  end

  return inject_after_startuml(
    source,
    table.concat(fragments, "\n")
  )
end

function Compiler.mime_type(config)
    local format = tostring(config.format)

    local mime = MIME_TYPES[format]

    if mime == nil then
        error(
            "Formato PlantUML no soportado: "
            .. format
        )
    end

    return mime
end

function Compiler.compile(source, config)

    local format = tostring(config.format)

    -- Valida el formato y, de paso, asegura que existe un MIME asociado.
    Compiler.mime_type(config)

    local url =
        trim_trailing_slash(tostring(config.server))
        .. "/"
        .. format

    local contents = post_with_curl(url, source)

    if type(contents) ~= "string" or contents == "" then
        error(
            "PlantUML devolvió una respuesta vacía mediante POST: "
            .. url
        )
    end

    return Compiler.mime_type(config), contents
end

return Compiler

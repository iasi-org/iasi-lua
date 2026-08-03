# Renderizado del libro Quarto
#
# Uso desde la consola de R:
#   source("scripts/render.R")
#   render_book()         # HTML y PDF y lo que haya
#   render_book("html")   # solo HTML
#   render_book("pdf")    # solo PDF
#
# Uso desde una terminal:
#   Rscript R/render.R
#   Rscript R/render.R html
#   Rscript R/render.R pdf

find_project_root <- function(start = getwd()) {
  path <- normalizePath(start, winslash = "/", mustWork = TRUE)

  repeat {
    if (file.exists(file.path(path, "_quarto.yml"))) return(path)

    parent = dirname(path)

    if (identical(parent, path)) {
      stop(
        "No se encontró _quarto.yml en el directorio actual ",
        "ni en ninguno de sus directorios superiores.",
        call. = FALSE
      )
    }

    path = parent
  }
}

# Por si acaso hay que hacer tareas previas

run_pre_render <- function(project_root) {
   
   script = file.path(project_root, "R", "pre-render.R" )

  if (!file.exists(script)) {
    message("No existe scripts/pre-render.R; se continúa sin él.")
    return(invisible(FALSE))
  }

  message("Ejecutando pre-render: ", script)

  previous_dir <- setwd(project_root)
  on.exit(setwd(previous_dir), add = TRUE)

  source(
    script,
    local = new.env(parent = globalenv()),
    chdir = FALSE,
    encoding = "UTF-8"
  )

  invisible(TRUE)
}

render_format <- function(format, project_root) {
  output_dir <- file.path("outputs", format)

  dir.create(
    file.path(project_root, output_dir),
    recursive = TRUE,
    showWarnings = FALSE
  )

  message("")
  message("Generando ", toupper(format), "...")
  message("Salida: ", file.path(project_root, output_dir))

  quarto::quarto_render(
    input = project_root,
    output_format = format,
    quarto_args = c(
      "--output-dir",
      output_dir
    )
  )

  message(toupper(format), " generado correctamente.")
}

render_book <- function(format = NULL) {
  if (!requireNamespace("quarto", quietly = TRUE)) {
    stop(
      "Falta el paquete R 'quarto'. Instálalo con:\n",
      "install.packages(\"quarto\")",
      call. = FALSE
    )
  }

  project_root <- find_project_root()

  if (
    is.null(format) ||
    length(format) == 0L ||
    !nzchar(trimws(format[[1]]))
  ) {
    formats <- c("html", "pdf")
  } else {
    format <- tolower(trimws(format[[1]]))

    if (format %in% c("all", "todos")) {
      formats <- c("html", "pdf")
    } else if (format %in% c("html", "pdf")) {
      formats <- format
    } else {
      stop(
        "Formato no válido: ", format, "\n",
        "Valores permitidos: html, pdf, all o todos.",
        call. = FALSE
      )
    }
  }

  message("Proyecto: ", project_root)
  message("Formatos: ", paste(formats, collapse = ", "))

  # Se ejecuta antes de invocar Quarto para que pueda regenerar
  # referencias o configuración incluso si se han renombrado archivos.
  # run_pre_render(project_root)

  for (current_format in formats) {
    render_format(current_format, project_root)
  }

  message("")
  message("Renderizado terminado.")
  invisible(formats)
}

# Cuando el archivo se ejecuta con Rscript, procesa el argumento recibido.
# Al cargarlo mediante source(), solo define las funciones.
if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  selected_format <- if (length(args)) args[[1]] else NULL
  render_book(selected_format)
}

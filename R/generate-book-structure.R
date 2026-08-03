# ==============================================================================
# Archivo:
#   R/generate-book-structure.R
#
# Propósito:
#   Generar automáticamente la estructura del libro Quarto a partir de los
#   directorios y archivos .qmd contenidos en chapters/.
#
# Descripción:
#   Cada directorio inmediato de chapters/ representa una parte del libro.
#   Su index.qmd actúa como introducción de la parte.
#
#   Los demás archivos .qmd se incorporan automáticamente, ordenados por nombre.
#   Por tanto, los prefijos numéricos determinan el orden editorial.
#
# Autor:
#   Javier G. Grandez
#
# Versión:
#   0.1.0
#
# Fecha:
#   2026-07-31
#
# Entrada:
#   chapters/<parte>/index.qmd
#   chapters/<parte>/*.qmd
#
# Salida:
#   _book-structure.yml
#
# Dependencias:
#   R base
#
# ==============================================================================


CONFIG = list(
   chapters_dir = "chapters"
  ,root_index   = "index.qmd"
  ,front_matter = c( "manifesto.qmd","principles.qmd"                   )
  ,back_matter  = c("licenses.qmd")
  ,part_index   = "index.qmd"
  ,output_file  = "_book-structure.yml"
)

normalise_path = function(path) {
  gsub("\\\\", "/", path)
}


discover_parts = function(chapters_dir) {
  parts = list.dirs(chapters_dir, recursive = FALSE, full.names = TRUE)
  sort(parts)
}


discover_chapters = function(part_dir) {
  chapters = list.files(part_dir, pattern = "\\.qmd$", full.names = TRUE,recursive = FALSE,ignore.case = TRUE)
  chapters = chapters[tolower(basename(chapters)) != CONFIG$part_index]
  sort(chapters)
}

validate_documents = function(files, description) {
  missing_files = files[!file.exists(files)]

  if (length(missing_files) > 0L) {
      stop(paste(sprintf("No se encuentran los documentos de %s:", description),
                         paste0(" - ", missing_files, collapse = "\n" ), sep = "\n"),
           call. = FALSE)
  }
  invisible(TRUE)
}

build_part_yaml = function(part_dir) {
  part_index = file.path(part_dir, CONFIG$part_index)

  if (!file.exists(part_index)) {
    stop(sprintf("La parte '%s' no contiene index.qmd.", normalise_path(part_dir)), call. = FALSE)
  }

  chapters = discover_chapters(part_dir)

  lines = c(paste0("    - part: \"", normalise_path(part_index), "\""))

  if (length(chapters) > 0L) lines = c(lines, "      chapters:", paste0("        - \"", normalise_path(chapters), "\""))
  lines
}


build_book_yaml = function(parts) {
  initial_documents = c(
     CONFIG$root_index
    ,CONFIG$front_matter
  )

  lines = c("book:", "  chapters:",
            paste0("    - \"", initial_documents, "\"" )
           )

  for (part in parts) {
    lines = c(lines, build_part_yaml(part))
  }

  lines = c(lines, paste0("    - \"", CONFIG$back_matter, "\""))
  lines
}

read_file = function(path) {
  if (!file.exists(path)) return(character())
  readLines(path, warn = FALSE, encoding = "UTF-8")
}


write_if_changed = function(content, path) {
  current_content = read_file(path)

  if (identical(current_content, content)) {
    message("La estructura del libro no ha cambiado.")
    return(FALSE)
  }

  writeLines(content, path, useBytes = TRUE)
  message("Estructura del libro actualizada.")
  TRUE
}


main = function() {
  if (!dir.exists(CONFIG$chapters_dir)) {
    stop(sprintf("No existe el directorio '%s'.", CONFIG$chapters_dir), call. = FALSE)
  }

  validate_documents(CONFIG$front_matter,"apertura")
  validate_documents(CONFIG$back_matter, "cierre"  )

  parts = discover_parts(CONFIG$chapters_dir)
  yaml = build_book_yaml(parts)
  write_if_changed(yaml,CONFIG$output_file)
  invisible(TRUE)
}

main()
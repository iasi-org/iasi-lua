# ==============================================================================
# Archivo:
#   R/generate-book-structure.R
#
# Propósito:
#   Generar automáticamente la estructura de un libro Quarto.
#
# Convenciones:
#   - index.qmd en la raíz es obligatorio y actúa como portada.
#   - Los documentos de apertura y cierre son opcionales.
#   - Cada subdirectorio inmediato de chapters/ que contenga documentos .qmd
#     representa una parte y debe contener index.qmd.
#   - Los prefijos numéricos determinan el orden editorial.
#
# Salida:
#   _book-structure.yml
#
# Dependencias:
#   R base
#
# ==============================================================================

CONFIG <- list(
  chapters_dir = "chapters",
  root_index = "index.qmd",
  front_matter = c(
    "manifesto.qmd",
    "principles.qmd"
  ),
  back_matter = c(
    "references.qmd",
    "licenses.qmd"
  ),
  part_index = "index.qmd",
  output_file = "_book-structure.yml",
  ignored_suffixes = c(
    ".bak",
    ".tmp",
    ".old",
    "~"
  )
)

normalise_path <- function(path) {
  gsub("\\\\", "/", path)
}

yaml_quote <- function(value) {
  value <- gsub("\\\\", "\\\\\\\\", value)
  value <- gsub("\"", "\\\\\"", value)
  paste0("\"", value, "\"")
}

is_ignored_file <- function(path) {
  name <- basename(path)

  if (startsWith(name, ".")) {
    return(TRUE)
  }

  any(vapply(
    CONFIG$ignored_suffixes,
    function(suffix) endsWith(tolower(name), tolower(suffix)),
    logical(1)
  ))
}

list_qmd_files <- function(path) {
  if (!dir.exists(path)) {
    return(character())
  }

  files <- list.files(
    path,
    pattern = "\\.qmd$",
    full.names = TRUE,
    recursive = FALSE,
    ignore.case = TRUE
  )

  files <- files[!vapply(files, is_ignored_file, logical(1))]
  sort(files)
}

find_file_case_insensitive <- function(path) {
  directory <- dirname(path)
  expected <- basename(path)

  if (!dir.exists(directory)) {
    return(NA_character_)
  }

  candidates <- list.files(
    directory,
    full.names = TRUE,
    recursive = FALSE,
    all.files = TRUE,
    no.. = TRUE
  )

  matches <- candidates[
    tolower(basename(candidates)) == tolower(expected)
  ]

  if (length(matches) == 0L) {
    return(NA_character_)
  }

  if (length(matches) > 1L) {
    stop(
      sprintf(
        "Existen varios archivos que coinciden con '%s' ignorando mayúsculas.",
        normalise_path(path)
      ),
      call. = FALSE
    )
  }

  matches[[1L]]
}

resolve_required_file <- function(path, description) {
  resolved <- find_file_case_insensitive(path)

  if (is.na(resolved)) {
    stop(
      sprintf(
        "No se encuentra %s: '%s'.",
        description,
        normalise_path(path)
      ),
      call. = FALSE
    )
  }

  if (basename(resolved) != basename(path)) {
    warning(
      sprintf(
        "El archivo '%s' usa mayúsculas distintas de la convención '%s'.",
        normalise_path(resolved),
        normalise_path(path)
      ),
      call. = FALSE
    )
  }

  resolved
}

resolve_optional_files <- function(files, description) {
  resolved <- character()

  for (path in files) {
    match <- find_file_case_insensitive(path)

    if (is.na(match)) {
      message(
        sprintf(
          "Documento opcional de %s ausente: %s",
          description,
          normalise_path(path)
        )
      )
      next
    }

    if (basename(match) != basename(path)) {
      warning(
        sprintf(
          "El archivo '%s' usa mayúsculas distintas de la convención '%s'.",
          normalise_path(match),
          normalise_path(path)
        ),
        call. = FALSE
      )
    }

    resolved <- c(resolved, match)
  }

  resolved
}

discover_parts <- function(chapters_dir) {
  if (!dir.exists(chapters_dir)) {
    message(
      sprintf(
        "No existe '%s'; se generará un libro sin partes.",
        normalise_path(chapters_dir)
      )
    )
    return(character())
  }

  parts <- list.dirs(
    chapters_dir,
    recursive = FALSE,
    full.names = TRUE
  )

  parts <- parts[!startsWith(basename(parts), ".")]
  sort(parts)
}

discover_chapters <- function(part_dir, part_index) {
  chapters <- list_qmd_files(part_dir)

  chapters[
    tolower(basename(chapters)) != tolower(basename(part_index))
  ]
}

build_part_yaml <- function(part_dir) {
  qmd_files <- list_qmd_files(part_dir)

  # Una carpeta sin documentos Quarto no forma parte del libro.
  if (length(qmd_files) == 0L) {
    message(
      sprintf(
        "Directorio ignorado porque no contiene .qmd: %s",
        normalise_path(part_dir)
      )
    )
    return(character())
  }

  expected_index <- file.path(part_dir, CONFIG$part_index)
  part_index <- resolve_required_file(
    expected_index,
    sprintf("el índice de la parte '%s'", normalise_path(part_dir))
  )

  chapters <- discover_chapters(part_dir, part_index)

  lines <- paste0(
    "    - part: ",
    yaml_quote(normalise_path(part_index))
  )

  if (length(chapters) > 0L) {
    lines <- c(
      lines,
      "      chapters:",
      paste0(
        "        - ",
        vapply(
          normalise_path(chapters),
          yaml_quote,
          character(1)
        )
      )
    )
  }

  lines
}

discover_unconfigured_root_documents <- function(
  root_index,
  front_matter,
  back_matter
) {
  configured <- tolower(basename(c(
    root_index,
    front_matter,
    back_matter
  )))

  root_documents <- list_qmd_files(".")

  root_documents[
    !tolower(basename(root_documents)) %in% configured
  ]
}

build_book_yaml <- function(
  root_index,
  front_matter,
  parts,
  back_matter
) {
  extra_root_documents <- discover_unconfigured_root_documents(
    root_index,
    front_matter,
    back_matter
  )

  if (length(extra_root_documents) > 0L) {
    message(
      paste(
        "Documentos raíz no configurados añadidos antes de las partes:",
        paste(
          paste0(" - ", normalise_path(extra_root_documents)),
          collapse = "\n"
        ),
        sep = "\n"
      )
    )
  }

  initial_documents <- c(
    root_index,
    front_matter,
    extra_root_documents
  )

  lines <- c(
    "book:",
    "  chapters:",
    paste0(
      "    - ",
      vapply(
        normalise_path(initial_documents),
        yaml_quote,
        character(1)
      )
    )
  )

  for (part in parts) {
    lines <- c(lines, build_part_yaml(part))
  }

  if (length(back_matter) > 0L) {
    lines <- c(
      lines,
      paste0(
        "    - ",
        vapply(
          normalise_path(back_matter),
          yaml_quote,
          character(1)
        )
      )
    )
  }

  lines
}

read_file <- function(path) {
  if (!file.exists(path)) {
    return(character())
  }

  readLines(path, warn = FALSE, encoding = "UTF-8")
}

write_atomic <- function(content, path) {
  directory <- dirname(path)

  if (!dir.exists(directory)) {
    dir.create(directory, recursive = TRUE)
  }

  temporary <- tempfile(
    pattern = paste0(".", basename(path), "-"),
    tmpdir = directory
  )

  on.exit(unlink(temporary), add = TRUE)

  writeLines(
    content,
    temporary,
    useBytes = TRUE
  )

  if (file.exists(path) && !file.remove(path)) {
    stop(
      sprintf(
        "No se pudo reemplazar '%s'.",
        normalise_path(path)
      ),
      call. = FALSE
    )
  }

  if (!file.rename(temporary, path)) {
    stop(
      sprintf(
        "No se pudo mover el archivo temporal a '%s'.",
        normalise_path(path)
      ),
      call. = FALSE
    )
  }
}

write_if_changed <- function(content, path) {
  current_content <- read_file(path)

  if (identical(current_content, content)) {
    message("La estructura del libro no ha cambiado.")
    return(FALSE)
  }

  write_atomic(content, path)
  message(
    sprintf(
      "Estructura del libro actualizada: %s",
      normalise_path(path)
    )
  )

  TRUE
}

main <- function() {
  root_index <- resolve_required_file(
    CONFIG$root_index,
    "la portada del libro"
  )

  front_matter <- resolve_optional_files(
    CONFIG$front_matter,
    "apertura"
  )

  back_matter <- resolve_optional_files(
    CONFIG$back_matter,
    "cierre"
  )

  parts <- discover_parts(CONFIG$chapters_dir)

  yaml <- build_book_yaml(
    root_index,
    front_matter,
    parts,
    back_matter
  )

  write_if_changed(
    yaml,
    CONFIG$output_file
  )

  invisible(TRUE)
}

main()

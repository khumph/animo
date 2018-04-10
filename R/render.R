#' Render an Rmd document
#'
#' Automatically determine output directory and output format based on a
#' specified path, e.g., results/output_doc.html would knit an html file
#' "output_doc.html" in the results subdirectory of the present working
#' directory.
#'
#' Currently only inplemented to knit word or html documents
#'
#' @param args command line arguments (1) path to input and filename (2) path to
#'  output file and filename
main <- function() {
  args <- commandArgs(trailingOnly = T)
  input_file <- args[1]
  output_path <- args[2]

  output_path_separated <- strsplit(output_path, "\\/")[[1]]
  if (length(output_path_separated) > 1) {
    output_file <- tail(output_path_separated, 1)
    output_dir <- paste0(head(output_path_separated, -1), collapse = "/")
  } else {
    output_file <- output_path
    output_dir <- NULL
  }

  output_extension <- tail(strsplit(output_file, "\\.")[[1]], 1)

  rmarkdown::render(input = input_file,
                    output_format = ifelse(output_extension == "docx",
                                           "word_document", "html_document"),
                    output_file = output_file,
                    output_dir = output_dir)
}

main()

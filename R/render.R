main <- function() {
  args <- commandArgs(trailingOnly = T)
  input_file <- args[1]
  output_file <- args[2]
  output_dir <- args[3]
  output_extension <- strsplit(output_file, split = "\\.")[[1]][-1]

  rmarkdown::render(input = input_file,
                    output_format = ifelse(output_extension == "docx",
                                           "word_document", "html_document"),
                    output_file = output_file,
                    output_dir = output_dir)
}

main()

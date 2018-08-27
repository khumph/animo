"Render a .Rmd document

Usage:
  render.R <rmd> <output_dir> <output> [<input_data>...]
  render.R -h | --help

Arguments:
  -h --help   Show this screen
  rmd         Filename of the .Rmd file to render
  output_dir  Directory to save output file
  output      Filename of the desired output file
  input_data  Data files required to knit document (passed to Rmarkdown as parameters)

Only inplemented to knit word or .html documents.
" -> doc

pacman::p_load(rmarkdown, docopt)
opts <- docopt::docopt(doc)

main <- function(input_file, output_dir, output_file, input_data) {

  if (length(input_data) > 0) {
    input_data <- list(input_data = input_data)
  } else {
    input_data <- NULL
  }

  output_extension <- tail(strsplit(output_file, "\\.")[[1]], 1)

  rmarkdown::render(input = input_file,
                    output_format = ifelse(output_extension == "docx",
                                           "word_document", "html_document"),
                    params = input_data,
                    output_file = output_file,
                    output_dir = output_dir)
}

main(opts$rmd, opts$output_dir, opts$output, opts$input_data)

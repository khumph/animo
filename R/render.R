"Render a .Rmd document

Usage:
  render.R INPUT_RMD OUTPUT_DIR OUTPUT [<input-data>...]

Arguments:
  INPUT_RMD   Filename of the .Rmd file to render
  OUTPUT_DIR  Directory to save output file
  OUTPUT      Filename of the desired output file
  input-data  Data files required to knit document, passed to Rmarkdown as parameters

Only inplemented to knit word or .html documents.
" -> doc

pacman::p_load(rmarkdown, docopt)
opts <- docopt::docopt(doc)
print(opts)
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

main(opts$INPUT, opts$OUTPUT_DIR, opts$OUTPUT, opts[["input-data"]])

"Converts an Excel file to a .csv file

Usage:
  convert-excel-csv.R <input> <output>

Arguments:
  input   Path to Excel file to convert
  output  Path to output .csv file
" -> doc

pacman::p_load(readxl)
opts <- docopt::docopt(doc)

main <- function(input_file, output_file) {

  output_df <- read_excel(input_file)
  write.csv(output_df, output_file, row.names = F)
}

main(opts$input, opts$output)

pacman::p_load(readxl)

main <- function() {
  args <- commandArgs(trailingOnly = T)
  input_file <- args[1]
  output_file <- args[2]

  output_df <- read_excel(input_file)
  write.csv(output_df, output_file, row.names = F)
}

main()


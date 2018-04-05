library(tidyverse)


main <- function() {
  args <- commandArgs(trailingOnly = T)
  input_files <- head(args, -1)

  map(input_files, ~ read.csv(.x, stringsAsFactors = F)) %>%
    reduce(full_join) %>%
    write.csv(row.names = F)
}


main()

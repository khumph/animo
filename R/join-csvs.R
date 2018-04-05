library(tidyverse)


main <- function() {
  args <- commandArgs(trailingOnly = T)
  input_files <- head(args, -1)

  dfs <- map(input_files, ~ read.csv(.x, stringsAsFactors = F))

  variables_shared <- map(dfs, names) %>% reduce(intersect)

  reduce(dfs, full_join, by = variables_shared) %>%
    write.csv(row.names = F)
}


main()

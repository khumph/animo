library(tidyverse)

clean <- function(df) {
  df %>%
    rename(participant_id = patient_id,
           week = time.point,
           pct_fat = TB_tissue_pfat) %>%
    mutate(participant_id = str_sub(participant_id, -2) %>% as.integer(),
           week = (week - 1) * 12)
}

main <- function() {
  args <- commandArgs(trailingOnly = T)
  input_file <- args[1]
  output_file <- args[2]

  read.csv(input_file, stringsAsFactors = F) %>%
    clean() %>%
    write.csv(file = output_file, row.names = F)
}


main()

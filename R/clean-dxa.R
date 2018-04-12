library(tidyverse)

clean <- function(df) {
  df %>%
    mutate_at(vars(`time point`, TB_tissue_pfat),
              funs(parse_number)) %>%
    rename(participant_id = patient_id,
           week = `time point`,
           pct_fat = TB_tissue_pfat) %>%
    mutate(participant_id = str_sub(participant_id, -2) %>% as.integer(),
           week = (week - 1) * 12)
}

main <- function() {
  args <- commandArgs(trailingOnly = T)
  input_file <- args[1]
  output_file <- args[2]

  read_csv(input_file,
           col_types = cols(.default = col_character())) %>%
    clean() %>%
    write_rds(output_file)
}


main()

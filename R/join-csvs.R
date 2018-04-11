library(tidyverse)


main <- function() {
  args <- commandArgs(trailingOnly = T)
  input_files <- head(args, -1)

  map(input_files, ~ read_csv(.x)) %>%
    reduce(full_join) %>%
    # age and group label on every observation (not just when recorded)
    group_by(participant_id) %>%
    mutate(group = mean(group, na.rm = T), age = mean(age, na.rm = T)) %>%
    ungroup() %>%
    write.csv(row.names = F)
}


main()

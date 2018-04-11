library(tidyverse)


main <- function() {
  args <- commandArgs(trailingOnly = T)
  input_files <- head(args, -1)
  output_file <- tail(args, 1)

  map(input_files, ~ read_rds(.x)) %>%
    reduce(full_join) %>%
    # age and group label on every observation (not just when recorded)
    mutate_at(vars(group, age),
              funs(parse_number)) %>%
    group_by(participant_id) %>%
    mutate(group = mean(group, na.rm = T), age = mean(age, na.rm = T)) %>%
    ungroup() %>%
    write_rds(output_file)
}


main()

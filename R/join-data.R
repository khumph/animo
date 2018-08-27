"Join .rds files into a single file

Usage:
  join-data.R <inputs>... (-o <out> | --output <out>)
  join-data.R -h | --help

Arguments:
  -h --help                Show this screen
  inputs                   .rds files to join
  -o <out> --output <out>  .rds of joined cleaned data

Files are joined on any and all columns/variables in common, then final data
transformation is performed.
" -> doc

pacman::p_load(tidyverse)
opts <- docopt::docopt(doc)


clean <- function(df) {
  df %>%
    # age and group label on every observation (not just when recorded)
    mutate_at(vars(group, age),
              funs(parse_number)) %>%
    group_by(participant_id) %>%
    mutate(group = mean(group, na.rm = T),
           age = mean(age, na.rm = T)) %>%
    ungroup() %>%
    # change group to factor, label
    mutate(group = factor(group, 0:1, c("WLC", "GCSWLI")))
}


main <- function(input_files, output_file) {
  map(input_files, ~ read_rds(.x)) %>%
    reduce(full_join) %>%
    clean() %>%
    write_rds(output_file)
}


main(opts$inputs, opts$output)

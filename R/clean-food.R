"Clean SW food frequency questionnaire data

Usage:
  clean-food.R <inputs>... (-o <out> | --output <out>)
  clean-food.R -h | --help

Arguments:
  -h --help                Show this screen
  inputs                    .csv files of raw SW food frequency questionnaire data
  -o <out> --output <out>  .rds of cleaned data
" -> doc

pacman::p_load(tidyverse)
opts <- docopt::docopt(doc)


clean <- function(food_dfs_list) {
  map2_df(
    food_dfs_list,
    c(0L, 12L, 24L),
    ~ .x %>%
      # subset to variables of interest in each df
      select(participant_id = sid, kcals_per_day = ener) %>%
      # convert ids to match animo, add week variable
      mutate(
        participant_id = parse_integer(participant_id),
        week = .y,
        kcals_per_day = parse_number(kcals_per_day)
      )
  )
}


main <- function(input_files, output_file) {

  map(input_files,
      ~ read_csv(.x, col_types = cols(.default = col_character()))) %>%
    clean() %>%
    write_rds(output_file)
}


main(opts$inputs, opts$output)

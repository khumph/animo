pacman::p_load(tidyverse)

#' Clean food data
#'
#' Extracts the calories consumed per day from the food questionnaires, puts
#' them in a format for easy combining with the rest of the data
#'
#' @param food_dfs_list list of the food data in chronological order
#' (week 0, week 12, week 24)
#'
#' @return Combined data frame of calories consumed
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


main <- function() {
  args <- commandArgs(trailingOnly = T)
  # input files are all command line arugments besides the last
  input_files <- head(args, -1)
  # output file is the last command line argument
  output_file <- tail(args, 1)

  map(input_files,
      ~ read_csv(.x, col_types = cols(.default = col_character()))) %>%
    clean() %>%
    write_rds(output_file)
}


main()

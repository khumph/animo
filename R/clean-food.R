library(tidyverse)

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
      select(sid, kcals_per_day = ener) %>%
      # convert ids to match animo, add week variable
      mutate(
        participant_id = parse_integer(sid),
        week = .y
      )
  )
}


main <- function() {
  args <- commandArgs(trailingOnly = T)
  input_files <- args

  map(input_files, ~ read.csv(.x, stringsAsFactors = F)) %>%
    clean() %>%
    write.csv(row.names = F)
}


main()
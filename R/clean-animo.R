library(tidyverse)


#' Clean ANIMO data
clean_animo <- function(animo) {
  animo %>%
    mutate(
      # change id to a number
      participant_id = str_sub(participant_id, -2) %>% as.integer(),
      # change event names to weeks, and first event to week 0 (baseline)
      week = parse_number(redcap_event_name),
      week = ifelse(week == 1, 0, week) %>% as.integer()
    ) %>%
    rowwise() %>%
    mutate(
      # derive measurements (average of those taken at each assessment)
      weight = mean(
        c(
          weight_1_paf,
          weight_2_paf,
          weight_3_paf %>% as.numeric(),
          weight_1_paf_mini,
          weight_2_paf_mini,
          weight_3_paf_mini %>% as.numeric()
        ),
        na.rm = T
      ),
      waist = mean(c(waist_1_paf, waist_2_paf, waist_3_paf), na.rm = T)
    ) %>% ungroup()
}


clean <- function(df) {
  df %>%
    clean_animo() %>%
    derive_ltpa() %>%
    select(participant_id, group, week, weight, waist, age = age_esf, ltpa,
           ends_with("tss"), ends_with("arma"))
}


main <- function() {
  args <- commandArgs(trailingOnly = T)
  input_file <- args[1]
  dependencies <- args[-1]

  walk(dependencies, source)

  read.csv(input_file, stringsAsFactors = F) %>%
    clean() %>%
    write.csv(row.names = F)
}


main()

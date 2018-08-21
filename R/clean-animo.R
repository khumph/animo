"Clean data from the main REDCap project

Usage:
  clean-animo.R <input> <output> [<dependencies>...]

Arguments:
  input         Path to .csv of file of raw data from REDCap
  output        Path to write .rds file of cleaned data to
  dependencies  Files with required function definitions
" -> doc

pacman::p_load(tidyverse)
opts <- docopt::docopt(doc)


#' Clean ANIMO data
clean_animo <- function(animo) {
  animo %>%
    mutate_at(vars(starts_with("waist"), starts_with("weight"), bmi_paf),
              funs(parse_number)) %>%
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
          weight_3_paf,
          weight_1_paf_mini,
          weight_2_paf_mini,
          weight_3_paf_mini
        ),
        na.rm = T
      ),
      waist = mean(c(waist_1_paf, waist_2_paf, waist_3_paf), na.rm = T)
    ) %>%
    ungroup()
}


clean <- function(df) {
  df %>%
    clean_animo() %>%
    derive_ltpa() %>%
    select(participant_id, group, week, weight, waist, age = age_esf, ltpa,
           bmi_paf, ends_with("tss"), ends_with("arma"), ends_with("dq"),
           starts_with("heritage")) %>%
    clean_satisfaction() %>%
    clean_heritage() %>%
    clean_arsma() %>%
    clean_dq() %>%
    arrange(participant_id)
}


main <- function(input_file, output_file, dependencies) {

  # import all functions from dependencies (all clean-animo-*.R files)
  walk(dependencies, source)

  read_csv(input_file,
           col_types = cols(.default = col_character())) %>%
    clean() %>%
    write_rds(output_file)
}


main(opts$input, opts$output, opts$dependencies)

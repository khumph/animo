library(tidyverse)

#' Clean ANIMO data
clean_animo <- function(animo) {
  animo %>%
    # change id to a number
    mutate(participant_id = str_sub(participant_id, -2) %>% as.integer()) %>%
    # put group assignment, age on every observation (not just when recorded)
    group_by(participant_id) %>%
    mutate(age = age_esf[1]) %>%
    # change event names to weeks, and first event to week 0 (baseline)
    rowwise() %>%
    rename(week = redcap_event_name) %>%
    mutate(
      week = ifelse(week == 'Baseline', 0, parse_number(week)) %>% as.integer(),
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
    ) %>% ungroup()
}


#' Derive leasuire time physical activity
derive_ltpa <- function(animo) {
  animo %>%
    rowwise() %>%
    mutate(
      vigorous_ltpa_minutes =
        days_vig_rec_gpaq * (time_vig_rec_h_gpaq * 60 + time_vig_rec_min_gpaq),
      vigorous_ltpa_minutes = ifelse(vig_rec_gpaq == "No",
                                     0,
                                     vigorous_ltpa_minutes),
      moderate_ltpa_minutes =
        days_mod_rec_gpaq * (time_mod_rec_h_gpaq * 60 + time_mod_rec_min_gpaq),
      moderate_ltpa_minutes = ifelse(mod_rec_gpaq == "No",
                                     0,
                                     vigorous_ltpa_minutes),
      ltpa = vigorous_ltpa_minutes + moderate_ltpa_minutes
    )
}

convert_to_numeric <- function(variable) {
  ifelse(
    variable == "Very Satisfied",
    "4",
    ifelse(
      variable ==
        "Neither Satisfied Nor Dissatisfied",
      "0",
      ifelse(variable == "Very Dissatisfied",
             "-4",
             variable)
    )
  ) %>% as.numeric()
}

clean_satisfaction <- function(df) {
  df %>%
    rowwise() %>%
    mutate_at(vars(starts_with("chng"), progress_why_tss),
              funs(convert_to_numeric(.))) %>%
    mutate_at(vars(satisfied_tss, rec_tss),
              funs(ifelse(. == "", NA, .))) %>%
    ungroup()
}

clean <- function(df) {
  df %>%
    clean_animo() %>%
    derive_ltpa() %>%
    select(participant_id, group, week, weight, waist, age, ltpa,
           ends_with("tss")) %>%
    clean_satisfaction()
}


main <- function() {
  args <- commandArgs(trailingOnly = T)
  input_file <- args

  read.csv(input_file, stringsAsFactors = F) %>%
    clean() %>%
    write.csv(row.names = F)
}


main()

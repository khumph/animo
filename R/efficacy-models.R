rm(list = ls())
pacman::p_load(tidyverse, lme4)

main <- function() {
  args <- commandArgs(trailingOnly = T)
  # input file is the first command line argument
  input_file <- args[1]
  # output file is the last command line argument
  output_file <- tail(args, 1)

  animo <- read_rds(input_file) %>%
    # subset to weeks of interest, filter those who weren't randomized
    filter(week %in% c(0, 12, 24), !is.na(group)) %>%
    # change week and group to factors, label groups
    mutate(week = factor(week))

  macro_labels <- tribble(
    ~name_base,      ~label,                                         ~log_trans,
    "weight",        "Weight, kg",                                   F,
    "weight",        "Percent weight change",                        T,
    "waist",         "Waist circumference, cm",                      F,
    "pct_fat",       "Percent body fat",                             F,
    "ltpa",          "LTPA<sup>d</sup>, minutes/week",               F,
    "kcals_per_day", "Average caloric intake<sup>e</sup>, kcal/day", T
  )

  blood_labels <- tribble(
    ~name_base,      ~label,            ~log_trans,
    "hba1c",         "HbA1c",           T,
    "alt",           "ALT",             T,
    "ast",           "AST",             T,
    "cholesterol",   "Cholesterol",     T,
    "hdl",           "HDL Cholesterol", T,
    "ldl",           "LDL Cholesterol", T,
    "triglycerides", "Triglycerides",   T,
    "hscrp",         "hs-CRP",          T
  )

  #' Create log transformed variable names to put in model formulas
  label_dfs <- map(list(macro_labels, blood_labels),
                   ~ .x %>%
                     mutate(name = case_when(
                       log_trans ~ paste0("log(", name_base, ")"),
                       T ~ name_base
                     ))) %>%
    set_names(c("macro", "blood"))

  #' Run lmer models
  model_dfs <- map(label_dfs, function(label_df) {
    label_df %>%
      rowwise() %>%
      mutate(lmer_mod = lmer(
        paste0(name, ' ~ group * week + (1 | participant_id)') %>% as.formula(),
        data = animo
      ) %>% list())
  })


  linfct_means <- rbind(
    '0_WLC' = c(1, 0, 0, 0, 0, 0),
    '12_WLC' = c(1, 0, 1, 0, 0, 0),
    # '24_WLC' = c(1, 0, 0, 1, 0, 0),
    '0_GCSWLI' = c(1, 1, 0, 0, 0, 0),
    '12_GCSWLI' = c(1, 1, 1, 0, 1, 0),
    '24_GCSWLI' = c(1, 1, 0, 1, 0, 1)
  )

  linfct_diffs_base <- rbind(
    '12 - 0_WLC' = c(0, 0, 1, 0, 0, 0),
    # '24 - 0_WLC' = c(0, 0, 0, 1, 0, 0),
    '12 - 0_GCSWLI' = c(0, 0, 1, 0, 1, 0) #,
    # '24 - 0_GCSWLI' = c(0, 0, 0, 1, 0, 1)
  )

  linfct_diffs_grps <- rbind(
    # GCSWLI - WLC
    # "GCSWLI" after underscore in name to print on the GCSWLI line in the table
    '0_GCSWLI' = c(0, 1, 0, 0, 0, 0),
    '12_GCSWLI' = c(0, 0, 0, 0, 1, 0) #,
    # '24_GCSWLI - WLC' = c(0, 1, 0, 0, 0, 1)
  )


  linfcts <- list(means = linfct_means,
                  diffs_base = linfct_diffs_base,
                  diffs_grps = linfct_diffs_grps)


  #' Run constrasts
  glhts_dfs <- map(model_dfs, function(model_df) {
    map2(linfcts, names(linfcts),
         ~ model_df %>% mutate(comparison = .y, linfct = list(.x))) %>%
      reduce(bind_rows) %>%
      mutate(glht = multcomp::glht(lmer_mod, linfct) %>% list())
  })


  #' Get estimates and confidence intervals
  ests_dfs <- map(glhts_dfs, function(glhts_df) {
    glhts_df %>%
      mutate(
        output = full_join(
          broom::tidy(confint(glht, calpha = qnorm(.975))),
          broom::tidy(summary(glht, test = multcomp::adjusted(type = "none"))),
          by = c("lhs", "rhs", "estimate")
        ) %>% list()
      )
  })

  results_dfs <- map(ests_dfs, function(ests_df) {
    ests_df %>%
      mutate(
        present = glht$model@frame %>%
          group_by(week, group) %>%
          summarise_at(vars(1), funs(count_present = sum(!is.na(.)))) %>%
          ungroup() %>% list()
        )
  })


  write_rds(results_dfs, path = output_file)
}


main()

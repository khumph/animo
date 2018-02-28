# This file depends on other files. Run it in the after files sourced before it
# in outcomes-tables.Rmd

# variable names and labels for table -------------------------------------

blood_labels <- tibble(
  hba1c = "HbA1c",
  alt = "ALT",
  ast = "AST",
  cholesterol = "Cholesterol",
  hdl = "HDL Cholesterol",
  ldl = "LDL Cholesterol",
  triglycerides = "Triglycerides",
  hscrp = "hs-CRP"
)


# log transform variables -------------------------------------------------

blood_labels <- blood_labels %>%
  rename_all(funs(paste0("log(", ., ")")))


# run models --------------------------------------------------------------

blood_models <- map(
  names(blood_labels),
  ~ lmer(
    as.formula(paste(.x, '~', 'group * week + (1 | participant_id)')),
    data = animo)
) %>% set_names(names(blood_labels))


# obtain contrasts of interest --------------------------------------------

blood_glhts <- map(
  list(linfct_means, linfct_diffs_base, linfct_diffs_grps),
  ~ get_glhts(.x, blood_models, blood_labels)
) %>% set_names('means', 'diffs_base', 'diffs_grps')


# get confidence intervals, and p-values in table form --------------------

blood_results <- map2(blood_glhts, c(F, T, T),
                      ~ get_results(.x, .y, blood_labels)) %>%
  set_names('means', 'diffs_base', 'diffs_grps')

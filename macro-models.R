
# macro variable names and labels for table -------------------------------

macro_labels <- tibble(
  weight = "Weight (kg)",
  `log(weight)` = "Percent weight change",
  waist = "Waist circumference (cm)",
  pct_fat = "Percent body fat",
  total_PA_minutes = "LTPA (minutes/week)",
  kcals_per_day = "Average caloric intake (kcal/day)"
)

# models ------------------------------------------------------------------

macro_models <- map(
  names(macro_labels),
  ~ lmer(
    as.formula(paste(.x, '~', 'group * week + (1 | participant_id)')),
    data = animo %>% filter(!is.na(.x)))
) %>% set_names(names(macro_labels))


# contrasts ---------------------------------------------------------------

macro_glhts <- map(
  list(linfct_means, linfct_diffs_base, linfct_diffs_grps),
  ~ get_glhts(.x, macro_models, macro_labels)
) %>% set_names('means', 'diffs_base', 'diffs_grps')


# results -----------------------------------------------------------------

macro_results <- map2(macro_glhts, c(F, T, T), ~ get_results(.x, .y, macro_labels)) %>%
  set_names('means', 'diffs_base', 'diffs_grps')


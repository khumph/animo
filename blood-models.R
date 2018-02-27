blood_labels <- blood_labels %>%
  rename_all(funs(paste0("log(", ., ")")))

blood_models <- map(
  names(blood_labels),
  ~ lmer(
    as.formula(paste(.x, '~', 'group * week + (1 | participant_id)')),
    data = animo)
) %>% set_names(names(blood_labels))

blood_glhts <- map(
  list(linfct_means, linfct_diffs_base, linfct_diffs_grps),
  ~ get_glhts(.x, blood_models, blood_labels)
) %>% set_names('means', 'diffs_base', 'diffs_grps')

blood_results <- map2(blood_glhts, c(F, T, T),
                      ~ get_results(.x, .y, blood_labels)) %>%
  set_names('means', 'diffs_base', 'diffs_grps')




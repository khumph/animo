get_glhts <- function(linfct, models_list, labels_df) {
  map(
    names(labels_df),
    ~ glht(models_list[[.x]], linfct)
  ) %>% set_names(names(labels_df))
}

get_results_df <- function(glht_obj, variable_name, difference = T,
                           sigfigs = 3, digits = NULL,
                           log_transformed = str_detect(variable_name, 'log')) {
  # returns a formatted data frame with 95% confidence intervals and p-values
  #   resulting from the contrasts given in a multcomp::glht object
  # inputs: glht_obj, a multcomp::glht object with contrasts of interest
  #         variable name, the variable name of interest

  ci_df <- confint(glht_obj, calpha = qnorm(.975)) %>%
    broom::tidy() %>% select(-rhs)

  if (log_transformed) {
    if (difference) {
      ci_df <- ci_df %>% mutate_at(vars(-lhs), funs((exp(.) - 1) * 100))
    } else if (str_detect(variable_name, '\\+ 1')) {
      ci_df <- ci_df %>% mutate_at(vars(-lhs), funs((exp(.) - 1)))
    } else {
      ci_df <- ci_df %>% mutate_at(vars(-lhs), funs(exp))
    }
  }

  if (difference) {
    pval_df <-
      summary(object = glht_obj, test = adjusted(type = "none")) %>%
      broom::tidy() %>%
      select(lhs, p.value)

    results_df <- full_join(ci_df, pval_df, by = 'lhs')
  } else {
    results_df <- ci_df
  }

  if (difference & log_transformed) {
    results_df <- results_df %>%
      mutate_at(vars(estimate, conf.low, conf.high),
                funs(sprintf("%.1f", .)))
  } else {
    results_df <- results_df %>%
      rowwise() %>%
      mutate_at(vars(estimate, conf.low, conf.high),
                funs(format(., digits = sigfigs, scientific = F, trim = T)))
  }

  results_df <- results_df %>%
    mutate(estimate = paste0(estimate,
                             " (", conf.low, ", ", conf.high, ")")) %>%
    select(-starts_with('conf'))

  if (difference) {
    results_df <- results_df %>%
      mutate(p.value = ifelse(p.value < 0.01,
                              "p < 0.01",
                              sprintf("p = %#.2g", p.value)),
             estimate = paste0(estimate, ", ", p.value)) %>%
      select(-p.value)
  }

  results_df <- results_df %>%
    separate(lhs, into = c("week", "Group"), sep = "_") %>%
    spread(key = week, value = estimate) %>%
    mutate(variable = variable_name) %>%
    select(variable, everything()) %>%
    arrange(desc(Group))

  return(results_df)
}

get_results <- function(glht_list, difference = T, labels_df) {
  map2_df(glht_list, names(labels_df),
          ~ get_results_df(.x, .y, difference))
}

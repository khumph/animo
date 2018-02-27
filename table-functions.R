get_glhts <- function(linfct, models_list, labels_df) {
  map(
    names(labels_df),
    ~ glht(models_list[[.x]], linfct)
  ) %>% set_names(names(labels_df))
}

get_results_df <- function(glht_obj, variable_name, pvals = T) {
  # returns a formatted data frame with 95% confidence intervals and p-values
  #   resulting from the contrasts given in a multcomp::glht object
  # inputs: glht_obj, a multcomp::glht object with contrasts of interest
  #         variable name, the variable name of interest

  ci_df <- confint(glht_obj, calpha = qnorm(.975)) %>%
    broom::tidy() %>% select(-rhs)

  if (str_detect(variable_name, 'log')) {
    if (str_detect(variable_name, '\\+ 1')) {
      if (pvals == T) {
        ci_df <- ci_df %>% mutate_at(vars(-lhs), funs((exp(.) - 1) * 100))
      } else {
        ci_df <- ci_df %>% mutate_at(vars(-lhs), funs((exp(.) - 1)))
      }
    } else if (pvals == T) {
      ci_df <- ci_df %>% mutate_at(vars(-lhs), funs((exp(.) - 1) * 100))
    } else {
      ci_df <- ci_df %>% mutate_at(vars(-lhs), funs(exp))
    }
  }

  if (pvals == T) {
    pval_df <- summary(object = glht_obj, test = adjusted(type = "none")) %>%
      broom::tidy() %>%
      select(lhs, p.value)

    results_df <- full_join(ci_df, pval_df, by = 'lhs')

    results_df <- results_df %>%
      mutate_at(vars(estimate, conf.low, conf.high),
                funs(sprintf("%1.f", .)))
  } else {
    results_df <- ci_df %>%
      mutate_at(vars(estimate, conf.low, conf.high),
                funs(format(signif(., 3),
                            scientific = F,
                            trim = T, drop0trailing = T)))
  }

  results_df <- results_df %>%
    mutate(estimate = paste0(estimate,
                             " (", conf.low, ", ", conf.high, ")")) %>%
    select(-starts_with('conf'))

  if (pvals == T) {
    results_df <- results_df %>%
      mutate(p.value = ifelse(p.value < 0.001,
                              "p < 0.001",
                              sprintf("p = %#.3f", p.value)),
             estimate = paste0(estimate, ", ", p.value)) %>%
      select(-p.value)
  }

  results_df <- results_df %>%
    separate(lhs, into = c("week", "Group"), sep = "_") %>%
    spread(key = week, value = estimate) %>%
    arrange(desc(Group))

  return(results_df)
}

get_results <- function(glht_list, pvals = T, labels_df) {
  map2_df(glht_list, names(labels_df),
          ~ get_results_df(.x, .y, pvals))
}

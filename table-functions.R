# load cleaned data
# need for determining the number of (non-missing) observations for each week/group
# load here b/c won't be able to lexical scope it when knitting .Rmd otherwise
load('../data/animo-cleaned.Rdata')

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

  if (difference) {
    ci_df <- confint(glht_obj, calpha = qnorm(.975)) %>%
      broom::tidy() %>% select(-rhs)
    if (log_transformed & str_detect(variable_name, '\\+ 1')) {
      ci_df <- ci_df %>% mutate_at(vars(-lhs), funs((exp(.) - 1)))
    } else if (log_transformed) {
      ci_df <- ci_df %>% mutate_at(vars(-lhs), funs((exp(.) - 1) * 100))
    }

    pval_df <-
      summary(object = glht_obj, test = adjusted(type = "none")) %>%
      broom::tidy() %>%
      select(lhs, p.value)

    results_df <- full_join(ci_df, pval_df, by = 'lhs')

    if (log_transformed) {
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

    results_df <- results_df %>%
      mutate(p.value = ifelse(p.value < 0.01,
                              "p < 0.01",
                              sprintf("p = %#.2g", p.value)),
             estimate = paste0(estimate, ", ", p.value)) %>%
      select(-p.value)

    results_df <- results_df %>%
      separate(lhs, into = c("week", "group"), sep = "_")
  } else {
    results_df <- animo %>% select(group, week,
                                   str_replace(variable_name, "log\\(", "") %>%
                                     str_replace("\\)", "") %>%
                                     str_replace("\\ \\+ 1", "")) %>%
      group_by(group, week) %>%
      summarise_all(funs(avg = mean(., na.rm = T), SD = sd(., na.rm = T))) %>%
      rowwise() %>%
      mutate_at(vars(avg, SD),
                funs(format(., digits = sigfigs, scientific = F, trim = T))) %>%
      mutate(estimate = paste0(avg, " (", SD, ")")) %>%
      select(-avg, -SD) %>%
      mutate_all(as.character) %>%
      filter(!(group == "WLC" & week == 24))
  }
  results_df <- results_df %>%
    spread(key = week, value = estimate) %>%
    mutate(variable = variable_name) %>%
    select(variable, everything()) %>%
    ungroup() %>%
    arrange(group)

  return(results_df)
}

get_results <- function(glht_list, difference = T, labels_df) {
  map2_df(glht_list, names(labels_df),
          ~ get_results_df(.x, .y, difference))
}

present_obs_one_var_df <- function(variable_name) {
  var_name_trans <- variable_name
  variable_name <- str_replace(variable_name, "log\\(", "") %>%
    str_replace("\\)", "") %>% str_replace("\\ \\+ 1", "")
  animo %>% group_by(group, week) %>%
    select(group, week, variable_name) %>%
    summarise_all(funs(present = is.na(.) %>% `!` %>% sum())) %>%
    mutate(variable = var_name_trans) %>%
    select(variable, everything())
}

present_obs_all_df <- function(labels_df) {
  map_df(names(labels_df), ~ present_obs_one_var_df(.x)) %>%
    group_by(group, week) %>%
    summarise(present = median(present) %>% floor(),
              pct = present * 4) %>%
    mutate(present = paste0(present,
                            " (", sprintf("%1.f",pct), ")")) %>%
    filter(!(group == "WLC" & week == 24)) %>%
    select(group, week, present) %>%
    ungroup() %>%
    mutate_all(as.character) %>%
    mutate(group = paste0(group, "_present")) %>%
    spread(key = week, value = present)
}

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
                           log_transformed = str_detect(variable_name, 'log'),
                           mean_sd = T) {
  # returns a formatted data frame with 95% confidence intervals and p-values
  #   resulting from the contrasts given in a multcomp::glht object
  # inputs: glht_obj, a multcomp::glht object with contrasts of interest
  #         variable name, the variable name of interest

  if (difference) {
    ci_df <- confint(glht_obj, calpha = qnorm(.975)) %>%
      broom::tidy() %>% select(-rhs)

    if (log_transformed) {
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
      group_by(group, week)
    if (mean_sd) {
      results_df <- results_df %>%
        summarise_all(funs(center = mean(., na.rm = T), spread = sd(., na.rm = T)))
    } else {
      results_df <- results_df %>%
        summarise_all(funs(center = median(., na.rm = T),
                           spread = IQR(., na.rm = T)))
    }
    results_df <- results_df %>%
      rowwise() %>%
      mutate_at(vars(center, spread),
                funs(format(., digits = sigfigs, scientific = F, trim = T))) %>%
      mutate(estimate = paste0(center, " (", spread, ")")) %>%
      select(-center, -spread) %>%
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
          ~ get_results_df(.x, .y, difference, mean_sd = F))
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

run_models <- function(labels_df, df) {
  model_list <- map(
    names(labels_df),
    ~ lmer(
      as.formula(paste(.x, '~', 'group * week + (1 | participant_id)')),
      data = df %>% filter(!is.na(.x)))
  ) %>% set_names(names(labels_df))
}

run_contrasts <- function(model_list, labels_df) {
  map(
    list(linfct_means, linfct_diffs_base, linfct_diffs_grps),
    ~ get_glhts(.x, model_list, labels_df)
  ) %>% set_names('means', 'diffs_base', 'diffs_grps')
}

run_results <- function(glht_list, labels_df) {
  map2(glht_list, c(F, T, T),
                        ~ get_results(.x, .y, labels_df)) %>%
    set_names('means', 'diffs_base', 'diffs_grps')
}

run_all <- function(labels_df, df) {
  model_list <- run_models(labels_df, df)
  glht_list <- run_contrasts(model_list, labels_df)
  run_results(glht_list, labels_df)
}

make_table <- function(results_list, labels_df, tfoot = "", ...) {
  results_list$means %>%
    bind_rows(present_obs_all_df(labels_df) %>% rename(variable = group)) %>%
    # remove means of percent weight beacuse they're geo means
    # not means of percent weight change
    mutate(`0` = ifelse(variable == "log(weight)", NA, `0`),
           `12` = ifelse(variable == "log(weight)", NA, `12`),
           `24` = ifelse(variable == "log(weight)", NA, `24`)) %>%
    full_join(results_list$diffs_base, by = c("variable", "group")) %>%
    full_join(results_list$diffs_grps, by = c("variable", "group")) %>%
    select(-variable, -group) %>%
    as.matrix() %>%
    `colnames<-`(c(
      "Baseline",
      "Week 12",
      "Week 24",
      "Week 12 - Baseline",
      "Baseline",
      "Week 12<sup>a</sup>"
    )) %>%
    htmlTable(
      rnames = rep(c("GCSWLI", "WLC"), nrow(.) / 2),
      rgroup = c(labels_df %>% flatten_chr(),
                 "Number of observations<sup>b</sup> (% of observations at baseline)") %>% rep(2),
      n.rgroup = rep(2, nrow(.) / 2),
      cgroup = c("Median assessments (IQR)", "Mean change from baseline",
                 "Mean differences between groups"),
      n.cgroup = c(3, 1, 2),
      tfoot = paste0("<sup>a</sup> Difference in change from baseline between groups at week 12\n<sup>b</sup> Actually the rounded down median number of observations, but all were within one observation of the median", tfoot),
      ...
    )
}

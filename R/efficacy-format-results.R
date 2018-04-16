pacman::p_load(tidyverse)

main <- function() {
  args <- commandArgs(trailingOnly = T)
  # input file is the first command line argument
  input_file <- args[1]
  # output file is the last command line argument
  output_file <- tail(args, 1)

  results_dfs <- read_rds(input_file)


  present_dfs <- map(results_dfs, function(results_df) {
    results_df %>%
      filter(comparison == "means") %>%
      select(present) %>%
      flatten_df() %>%
      filter(!(group == "WLC" & week == 24)) %>%
      group_by(group, week) %>%
      summarise(med_obs = median(count_present),
                max(count_present),
                min(count_present))
  })


  #' format estimates and confidence intervals for pretty printing on table
  formatted_results_dfs <- map(results_dfs, function(results_df) {
    results_df %>%
      mutate(
        output = output %>%
          rowwise() %>%
          mutate(
            p.value = case_when(p.value < 0.01 ~ "p < 0.01",
                                T ~ sprintf("p = %#.2g", p.value)),
            comparison = comparison,
            label = label
          ) %>%
          mutate_at(vars(estimate, conf.low, conf.high), funs(
            case_when(
              comparison != "means" & log_trans ~
                sprintf("%#.1f", (exp(.) - 1) * 100),
              name == "pct_fat" ~ sprintf("%#.1f", .),
              comparison == "means" ~
                ifelse(log_trans, exp(.), .) %>% signif(3) %>%
                formatC(digits = 3, format = "fg", flag = "#"),
              T ~ . %>% signif(2) %>%
                formatC(digits = 2, format = "fg", flag = "#")
            ) %>% str_remove("\\.$")
          )) %>%
          separate(lhs, into = c("week", "group"), sep = "_") %>%
          list()
      )
  })


  #' Put formatted estimates together
  output_dfs <- map(formatted_results_dfs, function(results_df) {
    comparison_labels <- results_df$comparison %>% unique()
    map(comparison_labels, ~ results_df %>% select(output) %>% flatten_df() %>%
          filter(comparison == .x)) %>%
      set_names(comparison_labels)
  })


  present_tabs <- map(present_dfs, function(present_df) {
    present_df %>%
      mutate(label = "Number of observations<sup>c</sup> (% of observations at baseline)",
             obs = round(med_obs),
             obs = paste0(obs, " (", ((obs / 25) * 100), ")")) %>%
      select(label, group, week, obs) %>%
      spread(week, obs) %>% arrange(desc(group)) %>%
      set_names(c("label", "group", "mean_base", "mean_w12", "mean_w24"))
  })


  #' combine and format data for each table
  tabs <- map2(output_dfs, present_tabs, function(output_df_list, present_tab) {
    map(output_df_list, function(output_df) {
      output_df %>%
        mutate(
          estimate = paste0(estimate, " (", conf.low, ", ", conf.high, ")"),
          estimate = ifelse(comparison != "means",
                            paste0(estimate, ", ", p.value),
                            estimate)
        ) %>%
        select(label, group, comparison, week, estimate) %>%
        ungroup() %>%
        group_by(label) %>%
        rownames_to_column() %>%
        mutate(order = rowname %>% as.numeric() %>% mean()) %>%
        select(-rowname) %>%
        spread(week, estimate) %>%
        arrange(order) %>%
        select(-order, -comparison)
    }) %>%
      reduce(full_join, by = c("label", "group")) %>%
      ungroup() %>%
      set_names(c("label", "group", "mean_base", "mean_w12", "mean_w24",
                  "diff_w12_base", "diff_grps_base", "diff_grps_w12")) %>%
      bind_rows(present_tab)
  })

  write_rds(tabs, path = output_file)

}

main()

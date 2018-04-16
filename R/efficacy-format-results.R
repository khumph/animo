pacman::p_load(tidyverse)

main <- function() {
  args <- commandArgs(trailingOnly = T)
  # input file is the first command line argument
  input_file <- args[1]
  # output file is the last command line argument
  output_file <- tail(args, 1)

  results_dfs <- read_rds(input_file)

  #' Combine the number of observations, SDs with estimates and CIs
  results_combined_dfs <- results_dfs %>% map(function(results_df) {
    results_df %>%
      mutate(
        output = output %>% mutate(
          order = order,
          comparison = comparison,
          name = name,
          log_trans = log_trans,
          label = label
        ) %>% separate(lhs, into = c("week", "group"), sep = "_") %>% list(),
        output =
          full_join(
            output,
            present %>% filter(comparison == "means", !(group == "WLC" & week == 24)),
        by = c("week", "group", "label", "comparison")) %>%
          list()
      ) %>% select(output) %>% flatten_df()
  })

  #' format estimates and confidence intervals for pretty printing on table
  output_dfs <- map(results_combined_dfs, function(results_df) {
    results_df %>%
      rowwise() %>%
      mutate(p.value = case_when(p.value < 0.01 ~ "p < 0.01",
                                 T ~ sprintf("p = %#.2g", p.value)),
             SD = signif(SD, 3) %>%
               formatC(digits = 3, format = "fg", flag = "#")) %>%
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
      ))
  })


  #' format the median number of observations at each time point to add to table
  present_tabs <- map(output_dfs, function(output_df) {
    output_df %>%
      filter(comparison == "means") %>%
      ungroup() %>% group_by(group, week) %>%
      summarise(med_obs = median(count_present)) %>%
      mutate(label = "Number of observations<sup>c</sup> (% of observations at baseline)",
             obs = round(med_obs),
             obs = paste0(obs, " (", ((obs / 25) * 100), ")")) %>%
      select(label, group, week, obs) %>%
      spread(week, obs) %>% arrange(group) %>%
      set_names(c("label", "group", "mean_base", "mean_w12", "mean_w24"))
  })


  #' Combine and format data for each table
  tabs <- map2(output_dfs, present_tabs, function(output_df, present_tab) {
    output_df <- output_df %>%
      mutate(estimate = case_when(
        comparison != "means" ~
          paste0(estimate, " (", conf.low, ", ", conf.high, "), ", p.value),
        # Mean percent weight changes are geo means, SDs are same as for weight
        # remove them from table
        comparison == "means" & name == "log(weight)" ~ "",
        T ~ paste0(estimate, " (", SD, ")"))
      ) %>%
      ungroup()

    comps <- output_df$comparison %>% unique()
    map(comps, function(comp){
      output_df %>%
        filter(comparison == comp) %>%
        select(label, group, order, week, estimate) %>%
        spread(week, estimate) %>%
        arrange(order) %>% select(-order)
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

library(tidyverse)

main <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  input_file <- args[1]
  output_file <- args[2]

  ltpa <- read.csv(input_file) %>%
    # subset to weeks of interest, filter those who weren't randomized
    filter(week %in% c(0, 12), !is.na(group)) %>%
    select(participant_id, group, week, ltpa) %>%
    # change week and group to factors, label groups
    mutate(week = as.character(week),
           group = factor(group, 0:1, c("WLC", "GCSWLI")) %>% as.character())

  # Wilcoxon signed rank for difference from baseline within each group
  wilcox_from_baseline <- map(
    c("GCSWLI", "WLC"), ~
      ltpa %>% filter(week == "0" | week == "12", group == .x) %>%
      wilcox.test(ltpa ~ week, paired = T, data = ., na.action = na.pass)
  ) %>% set_names(c("GCSWILI_12_0", "WLC_12_0"))


  # Wilcoxon rank sum for difference between groups at week 0 (baseline) and week 12
  wilcox_btwn_groups <- map(
    c("0", "12"), ~
      wilcox.test(ltpa ~ group, data = ltpa %>% filter(week == .x))
  ) %>%
    set_names(c("week_0", "week_12"))

  save(wilcox_btwn_groups, wilcox_from_baseline, file = output_file)
}


main()

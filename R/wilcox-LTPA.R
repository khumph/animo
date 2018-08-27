"Run Wilcoxon rank sum and signed rank tests for activity time outcome

Usage:
  wilcox-LTPA.R <input> (-o <out> | --output <out>)
  wilcox-LTPA.R -h | --help

Arguments:
  -h --help                Show this screen
  input                    .rds of full cleaned data
  -o <out> --output <out>  .Rdata file to save resulting models in
" -> doc

pacman::p_load(tidyverse)
opts <- docopt::docopt(doc)

main <- function(input_file, output_file) {

  animo <- read_rds(input_file)

  weeks <- c(0, 12)

  animo <- animo %>%
    # subset to weeks of interest, filter those who weren't randomized
    filter(week %in% weeks, !is.na(group))

  # Wilcoxon signed rank for difference from baseline within each group
  groups <- levels(animo$group)

  wilcox_from_baseline <- map(
    groups,
    ~
      wilcox.test(
        ltpa ~ week,
        data = filter(animo, group == .x),
        paired = T,
        na.action = na.pass
      )
  ) %>%
    set_names(groups)


  # Wilcoxon rank sum for difference between groups at week 0 (baseline) and week 12
  wilcox_btwn_groups <- map(
    weeks, ~
      wilcox.test(
        ltpa ~ group,
        data = filter(animo, week == .x)
      )
  ) %>%
    set_names(paste("week", weeks, sep = "_"))


  save(wilcox_btwn_groups, wilcox_from_baseline, file = output_file)
}


main(opts$input, opts$output)

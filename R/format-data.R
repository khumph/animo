library(tidyverse)

main <- function() {
  args <- commandArgs(trailingOnly = T)
  # input file is first command line argument
  input_file <- args[1]
  # output file is second command line argument
  output_file <- args[2]

  animo <- read_rds(input_file) %>%
    mutate(
      # change group to factor, label
      group = factor(group, 0:1, c("WLC", "GCSWLI")),
      # change satisfaction variables to factors
      satisfied_tss = factor(
        satisfied_tss,
        levels = 1:4,
        labels = c(
          "Very Dissatisfied",
          "Somewhat Dissatisfied",
          "Somewhat Satisfied",
          "Very Satisfied"
        )
      ),
      rec_tss = factor(
        rec_tss,
        levels = 1:4,
        labels = c(
          "Definitely Not",
          "Probably Not",
          "Probably Would",
          "Definitely Would"
        )
      )
    )

  write_rds(animo, path = output_file)
}

main()

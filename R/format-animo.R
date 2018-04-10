library(tidyverse)

main <- function() {
  args <- commandArgs(trailingOnly = T)
  input_csv <- args[1]
  output_Rdata <- args[2]

  animo <- read_csv(input_csv) %>%
    mutate(
      # change group to factor, label
      group = factor(group, 0:1, c("WLC", "GCSWLI")),
      # change satisfaction variables to factors
      satisfied_tss = factor(
        satisfied_tss,
        levels = c(
          "Very Dissatisfied",
          "Somewhat Dissatisfied",
          "Somewhat Satisfied",
          "Very Satisfied"
        )
      ),
      rec_tss = factor(
        rec_tss,
        levels = c(
          "Definitely Not",
          "Probably Not",
          "Probably Would",
          "Definitely Would"
        )
      )
    )

  save(animo, file = output_Rdata)
}

main()

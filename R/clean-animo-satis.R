clean_satisfaction <- function(df) {
  df %>%
    mutate_at(vars(ends_with("tss"), -unsatisfied_why_tss, -no_rec_why_tss),
              funs(parse_number)) %>%
    # change satisfaction variables to factors
    mutate(
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
}

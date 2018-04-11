clean_satisfaction <- function(df) {
  df %>%
    mutate_at(vars(ends_with("tss"), -unsatisfied_why_tss, -no_rec_why_tss),
              funs(parse_number)) %>%
    ungroup()
}

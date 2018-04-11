clean_satisfaction <- function(df) {
  df %>%
    mutate_at(vars(ends_with("tss"), -contains("why")),
              funs(parse_number)) %>%
    ungroup()
}

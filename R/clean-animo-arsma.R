clean_arsma <- function(df) {
  df %>%
    rowwise() %>%
    ungroup()
}

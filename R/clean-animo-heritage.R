clean_heritage <- function(df) {
  df %>%
    mutate_at(vars(starts_with("heritage"), -starts_with("heritage_other"),
                   -heritage_spec_dq),
              funs(parse_number)) %>%
    # determine heritage by the most common response given across the three
    # forms each of which asked the same question about heritage
    rowwise() %>%
    mutate(
      cuban = mean(c(heritage_esf___1, heritage_paf___1, heritage_dq___1), na.rm = T),
      mexican = mean(c(heritage_esf___2, heritage_paf___2, heritage_dq___2), na.rm = T),
      mexican_american = mean(c(heritage_esf___3, heritage_paf___3, heritage_dq___3), na.rm = T),
      puerto_rican = mean(c(heritage_esf___4, heritage_paf___4, heritage_dq___4), na.rm = T),
      south_central_american = mean(c(heritage_esf___5, heritage_paf___5, heritage_dq___5), na.rm = T),
      other_latino = mean(c(heritage_esf___6, heritage_paf___6, heritage_dq___6), na.rm = T),
      other = mean(c(heritage_esf___7, heritage_paf___7, heritage_dq___7), na.rm = T)
    ) %>%
    ungroup() %>%
    mutate_at(vars(cuban:other), funs(. > 0.5)) %>%
    rowwise() %>%
    mutate(
      heritage = ifelse(
        cuban, "Cuban",
        ifelse(
          mexican, "Mexican",
          ifelse(
            mexican_american, "Mexican-American",
            ifelse(
              puerto_rican, "Puerto Rican",
              ifelse(
                south_central_american, "South/Central American",
                ifelse(
                  other_latino, "Other Spanish, Hispanic, Latino",
                  ifelse(other, "Other", "???")
                )
              )
            )
          )
        )
      )
    ) %>%
    ungroup()
}

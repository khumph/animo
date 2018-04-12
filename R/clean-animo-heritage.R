#' Classify heritage response by the reponse given on at least two of the
#' three forms which ask the same question about heritage
herit <- function(var_num) {
  form_abbrevs <- c("esf", "paf", "dq")

  quo(
    mean(!!!
           rlang::syms(glue::glue("heritage_{form_abbrevs}___{var_num}")),
         na.rm = T) > 0.5
  )
}


clean_heritage <- function(df) {
  df %>%
    mutate_at(vars(starts_with("heritage"), -starts_with("heritage_other"),
                   -heritage_spec_dq),
              funs(parse_number)) %>%
    # determine heritage by the most common response given across the three
    # forms each of which asked the same question about heritage
    rowwise() %>%
    mutate(
      heritage = case_when(
        !! herit(1) ~ "Cuban",
        !! herit(2) ~ "Mexican",
        !! herit(3) ~ "Mexican-American",
        !! herit(4) ~ "Puerto Rican",
        !! herit(5) ~ "South/Central American",
        !! herit(6) ~ "Other Spanish, Hispanic, Latino",
        !! herit(7) ~ "Other"
      ),
      mexican_heritage = any(c("Mexican", "Mexican-American") %in% heritage)
    ) %>%
    ungroup()
}

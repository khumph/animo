#' Classify heritage response by the reponse given on at least two of the
#' three forms which ask the same question about heritage
herit_across_pafs <- function(var_num) {

  quo(
    sum(!!!
           rlang::syms(glue::glue("heritage_paf___{var_num}")),
         na.rm = T)
  )
}

# The same question about heritage was asked on three forms at baseline
# (eligibility screening form - esf, demographics questionnaire - dq,
# and the physical assessment form - paf) and also on two post baseline physical
# assessment forms (week 12 and 24)
# Classify heritage as the most common response across these five forms (i.e.,
# the one that's reported 3 or more times)
herit_across_forms <- function(var_num) {
  form_abbrevs <- c("esf", "paf", "dq")

  quo(
    sum(!!!
           rlang::syms(glue::glue("heritage_{form_abbrevs}___{var_num}")),
         na.rm = T) > 2
  )
}


clean_heritage <- function(df) {
  df %>%
    mutate_at(vars(starts_with("heritage"), -starts_with("heritage_other"),
                   -heritage_spec_dq),
              funs(parse_number)) %>%
    group_by(participant_id) %>%
    mutate(
      heritage_paf___1 = !! herit_across_pafs(1),
      heritage_paf___2 = !! herit_across_pafs(2),
      heritage_paf___3 = !! herit_across_pafs(3),
      heritage_paf___4 = !! herit_across_pafs(4),
      heritage_paf___5 = !! herit_across_pafs(5),
      heritage_paf___6 = !! herit_across_pafs(6),
      heritage_paf___7 = !! herit_across_pafs(7)
    ) %>%
    # determine heritage by the most common response given across the three
    # forms each of which asked the same question about heritage
    rowwise() %>%
    mutate(
      heritage = case_when(
        !! herit_across_forms(1) ~ "Cuban",
        !! herit_across_forms(2) ~ "Mexican",
        !! herit_across_forms(3) ~ "Mexican-American",
        !! herit_across_forms(4) ~ "Puerto Rican",
        !! herit_across_forms(5) ~ "South/Central American",
        !! herit_across_forms(6) ~ "Other Spanish, Hispanic, Latino",
        !! herit_across_forms(7) ~ "Other"
      ),
      mexican_heritage = any(c("Mexican", "Mexican-American") %in% heritage)
    ) %>%
    ungroup()
}

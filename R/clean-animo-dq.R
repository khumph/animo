clean_dq <- function(df) {

  df %>%
    # fix variable name spelling
    rename(employed_dq = empolyed_dq) %>%
    mutate(
      employed_dq = fct_recode(employed_dq,
                               "No" = "0",
                               "Yes" = "1"),
      partner_dq = fct_recode(partner_dq,
                               "No" = "0",
                               "Yes" = "1"),
      # collapse graduate degree into bachelors because only one person with
      # graduate degree
      grade_dq = fct_recode(
        grade_dq,
        "Grades 1 through 8" = "1",
        "Attended some high school" = "2",
        "Graduated high school or GED" = "3",
        "Some college" = "4",
        "Bachelor's degree or higher" = "5",
        "Bachelor's degree or higher" = "6"
      ),
      # All of the people who responded with an "other" language spoken at home
      # said they spoke both Spanish and English equally
      lang_home_dq = factor(
        lang_home_dq,
        levels = c("English", "Spanish", "Other (Please Specify)"),
        labels = c("English", "Spanish", "Both equally")
      )
    )

}

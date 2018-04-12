clean_arsma <- function(df) {
  df %>%
    # select only arsma vars
    mutate_at(vars(spanish_speak_arma:ma_close_arma), funs(parse_number)) %>%
    rowwise() %>%
    mutate(
      # score MOS
      MOS = sum(
        spanish_speak_arma,
        enjoy_span_arma,
        mexicans_arma,
        span_music_arma,
        span_tv_arma,
        span_movies_arma,
        span_read_arma,
        span_write_arma,
        span_think_arma,
        cont_mexico_arma,
        father_arma,
        mother_arma,
        child_friends_mexican_arma,
        mexican_food_arma,
        friends_mexican_arma,
        ma_ident_arma,
        mex_ident_arma
      ),
      # mean MOS, score only Mexicans and Mexican Americans (who the scale is
      # designed for)
      MOS_mean = ifelse(mexican | mexican_american, MOS / 17, NA),
      # score AOS
      AOS = sum(
        english_arma,
        anglos_arma,
        english_music_arma,
        english_tv_arma,
        english_movies_arma,
        english_read_arma,
        english_write_arma,
        english_think_arma,
        cont_usa_arma,
        child_friends_anglo_arma,
        friends_anglo_arma,
        anglo_ident_arma,
        amer_ident_arma
      ),
      # mean AOS, score only Mexicans and Mexican Americans (who the scale is
      # designed for)
      AOS_mean =  ifelse(mexican | mexican_american, AOS / 13, NA),
      # ARSMA score is difference between AOS mean and MOS mean
      arsma_score = AOS_mean - MOS_mean,
      # cateogrize ARMSA scores as in paper
      arsma_level = cut(
        arsma_score,
        breaks = c(-Inf, -1.33, -0.07, 1.19, 2.45, Inf),
        labels = c(
          "Very Mexican oriented",
          "Mexican oriented to approximately balanced bicultural",
          "Slightly Anglo oriented bicultural",
          "Strongly Anglo oriented",
          "Very assimilated; Anglicized"
        )
      )
    ) %>%
    ungroup()
}

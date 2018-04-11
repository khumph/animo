#' Derive leasuire time physical activity
derive_ltpa <- function(animo) {
  animo %>%
    rowwise() %>%
    mutate(
      vigorous_ltpa_minutes =
        days_vig_rec_gpaq * (time_vig_rec_h_gpaq * 60 + time_vig_rec_min_gpaq),
      vigorous_ltpa_minutes = ifelse(vig_rec_gpaq == 0,
                                     0,
                                     vigorous_ltpa_minutes),
      moderate_ltpa_minutes =
        days_mod_rec_gpaq * (time_mod_rec_h_gpaq * 60 + time_mod_rec_min_gpaq),
      moderate_ltpa_minutes = ifelse(mod_rec_gpaq == 0,
                                     0,
                                     vigorous_ltpa_minutes),
      ltpa = vigorous_ltpa_minutes + moderate_ltpa_minutes
    )
}

pacman::p_load(tidyverse)

clean <- function(df) {
  blood_base_labels <-
    tibble(
      old = c(
        "hemoglobin_a1c_glycated_he",
        "alt",
        "ast",
        "cholesterol",
        "hdl_cholesterol",
        "ldl_cholesterol",
        "triglycerides",
        "hs_crp"
      ),
      new = c(
        "hba1c",
        "alt",
        "ast",
        "cholesterol",
        "hdl",
        "ldl",
        "triglycerides",
        "hscrp"
      )
    )

  blood_labels_full <- outer(blood_base_labels$new, c("_0", "_12", "_24"),
                             FUN = "paste0") %>%
    t() %>%
    as.vector()

  blood <- df %>%
    # remove variables that also match variables of interest
    select(-starts_with("cholesterol_hdlc_ratio")) %>%
    # convert id to match animo
    mutate(participant_id = str_sub(record_id, -2) %>% as.integer())

  # select variables of interest
  blood <- bind_cols(
    blood %>% select(participant_id),
    map_dfc(blood_base_labels$old, ~ blood %>% select(starts_with(.x)))
  ) %>%
    # rename variables of interest for easy identification/reference
    set_names(c("participant_id", blood_labels_full))

  # convert to longitundinal form
  blood %>%
    gather(key, value, -participant_id) %>%
    separate(key, c('var', 'week'), convert = T) %>%
    spread(key = var, value = value, convert = T)
}

main <- function() {
  args <- commandArgs(trailingOnly = T)
  input_file <- args[1]
  output_file <- args[2]

  read_csv(input_file,
           col_types = cols(.default = col_character())) %>%
    clean() %>%
    write_rds(output_file)
}

main()

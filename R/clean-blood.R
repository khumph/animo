library(tidyverse)

clean_blood <- function(blood) {
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

  blood <- blood %>%
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
  functions_file <- args[1]
  input_file <- args[2]
  output_file <- args[3]

  source(functions_file)

  load_data(input_file) %>% clean_blood() %>%
    write.csv(file = output_file, row.names = F)
}

main()
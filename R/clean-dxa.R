"Clean DXA data

Usage:
  clean-dxa.R <input> (-o <out> | --output <out>)
  clean-dxa.R -h | --help

Arguments:
  -h --help                Show this screen
  input                    .csv of raw DXA data
  -o <out> --output <out>  .rds of cleaned data
" -> doc

pacman::p_load(tidyverse)
opts <- docopt::docopt(doc)


clean <- function(df) {
  df %>%
    mutate_at(vars(`time point`, TB_tissue_pfat),
              funs(parse_number)) %>%
    rename(participant_id = patient_id,
           week = `time point`,
           pct_fat = TB_tissue_pfat) %>%
    mutate(participant_id = str_sub(participant_id, -2) %>% as.integer(),
           week = (week - 1) * 12)
}


main <- function(input_file, output_file) {
read_csv(input_file,
           col_types = cols(.default = col_character())) %>%
    clean() %>%
    write_rds(output_file)
}


main(opts$input, opts$output)

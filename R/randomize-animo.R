"Create and save block randomized randomization list

Usage:
  randomize-animo.R <seed> <length> <output>

Arguments:
  seed    Seed for (pseudo)random number generation (for reproducibility)
  length  Total number of participants to randomize
  output  Path to output .csv file

Creates a random permuted block randomization list, blocks of size 2-4, two
groups, with four strata defined by the combinations of diabetes status
(yes/no) and bmi category (overweight/obese)
" -> doc

pacman::p_load(tidyverse, blockrand)
opts <- docopt::docopt(doc)

main <- function(seed, total_participants, output_filename) {

  set.seed(seed)

  # all combinations of variables defining strata, long enough to allow all
  # participants in a single stratum
  rand_list <- expand.grid(
    diabetes_mhf = rep(c(1, 0), each = total_participants),
    bmi_cat_r_paf = rep(c(1, 2))
  )

  num_strata <- nrow(rand_list / total_participants)

  group_assignments <- map(
    1:num_strata,
    ~ blockrand(
      n = total_participants,
      block.sizes = 1:2, # doubled: actually gives blocks of 2 and 4
    )$treatment[1:total_participants] # cut each to length of total participants
  ) %>% flatten_int() - 1 # - 1 to give assignments of 0 and 1, not 1 and 2

  rand_list <- data.frame(
    group = group_assignments,
    rand_list
  )

  write.csv(rand_list, file = output_filename, row.names = F, quote = F)
}

main(as.numeric(opts$seed), as.numeric(opts$length), opts$output)

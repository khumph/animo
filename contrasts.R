linfct_means <- rbind(
  'Baseline_WLC' = c(1, 0, 0, 0, 0, 0),
  'Week 12_WLC' = c(1, 0, 1, 0, 0, 0),
  # 'Week 24_WLC' = c(1, 0, 0, 1, 0, 0),
  'Baseline_GSCWLI' = c(1, 1, 0, 0, 0, 0),
  'Week 12_GSCWLI' = c(1, 1, 1, 0, 1, 0),
  'Week 24_GSCWLI' = c(1, 1, 0, 1, 0, 1)
)

linfct_diffs_base <- rbind(
  'Week 12 - Baseline_WLC' = c(0, 0, 1, 0, 0, 0),
  # 'Week 24 - Baseline_WLC' = c(0, 0, 0, 1, 0, 0),
  'Week 12 - Baseline_GSCWLI' = c(0, 0, 1, 0, 1, 0) #,
  # 'Week 24 - Baseline_GSCWLI' = c(0, 0, 0, 1, 0, 1)
)

linfct_diffs_grps <- rbind(
  # GSCWLI - WLC
  # "GCSWLI" after underscore in name to print on the GCSWLI line in the table
  'Baseline_GSCWLI' = c(0, 1, 0, 0, 0, 0),
  'Week 12_GSCWLI' = c(0, 0, 0, 0, 1, 0) #,
  # 'Week 24_GSCWLI - WLC' = c(0, 1, 0, 0, 0, 1)
)

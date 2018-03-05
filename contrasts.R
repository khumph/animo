linfct_means <- rbind(
  '0_WLC' = c(1, 0, 0, 0, 0, 0),
  '12_WLC' = c(1, 0, 1, 0, 0, 0),
  # '24_WLC' = c(1, 0, 0, 1, 0, 0),
  '0_GCSWLI' = c(1, 1, 0, 0, 0, 0),
  '12_GCSWLI' = c(1, 1, 1, 0, 1, 0),
  '24_GCSWLI' = c(1, 1, 0, 1, 0, 1)
)

linfct_diffs_base <- rbind(
  '12 - 0_WLC' = c(0, 0, 1, 0, 0, 0),
  # '24 - 0_WLC' = c(0, 0, 0, 1, 0, 0),
  '12 - 0_GCSWLI' = c(0, 0, 1, 0, 1, 0) #,
  # '24 - 0_GCSWLI' = c(0, 0, 0, 1, 0, 1)
)

linfct_diffs_grps <- rbind(
  # GCSWLI - WLC
  # "GCSWLI" after underscore in name to print on the GCSWLI line in the table
  '0_GCSWLI' = c(0, 1, 0, 0, 0, 0),
  '12_GCSWLI' = c(0, 0, 0, 0, 1, 0) #,
  # '24_GCSWLI - WLC' = c(0, 1, 0, 0, 0, 1)
)

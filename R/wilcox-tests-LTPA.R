library(magrittr)

load('../data/animo-cleaned.Rdata')

ltpa <- animo %>%
  select(participant_id, group, week, total_PA_minutes)

var_names <- expand.grid(week = c(0, 12, 24), group = c("GCSWLI", "WLC"))
vals <- map2(
  var_names$week, var_names$group,
  ~ ltpa %>% filter(week == .x, group == .y) %>%
    select(total_PA_minutes) %>% flatten_dbl()
) %>% set_names(
  var_names %>% mutate(name = paste0(group, "_", week)) %>%
    select(name) %>% flatten_chr()
)

# baseline
wilcox.test(vals$GCSWLI_0, vals$WLC_0)

# 12 to base diff
wilcox.test(vals$GCSWLI_12, vals$GCSWLI_0, paired = T)
wilcox.test(vals$WLC_12, vals$WLC_0, paired = T)

# between groups diff
wilcox.test(vals$GCSWLI_0, vals$WLC_0, paired = T)
wilcox.test(vals$GCSWLI_12 - vals$GCSWLI_0, vals$WLC_12 - vals$WLC_0, paired = T)

# setup packages ----------------------------------------------------------

rm(list = ls())
knitr::opts_chunk$set(warning = F, echo = F, message = F)
library(pacman)
p_load(Hmisc, readxl, lme4, multcomp, tidyverse, broom, Gmisc)
select <- dplyr::select


# load data ---------------------------------------------------------------

var_names <- read_csv('../data/animo.csv', col_names = F, n_max = 1) %>%
  flatten_chr()
animo <- read.csv('../data/animo-labels.csv', header = F, skip = 1, stringsAsFactors = F) %>%
  set_names(var_names)
dxa <- read_excel('../data/Nosotros DXA Data Final KH.xlsx')
blood <- read.csv('../data/animo-blood.csv', stringsAsFactors = F)
food_base <- read.csv('../data/Animo_baselinesum2009r_sw.csv', stringsAsFactors = F)
food_week_12 <- read.csv('../data/Animo_12wksum2009r_sw.csv', stringsAsFactors = F)
food_week_24 <- read.csv('../data/Animo_24wsum2009r_sw.csv', stringsAsFactors = F)


# clean amino data --------------------------------------------------------

animo <- animo %>%
  group_by(participant_id) %>%
  mutate(group = group[1], # puts group assignment label in every observation
         age = age_esf[1]) %>% # puts age on every observation
  rowwise() %>%
  # change event names to weeks, and first event to week 0 (baseline)
  mutate(
    week = ifelse(
      redcap_event_name == 'Baseline',
      0,
      parse_number(redcap_event_name)
    ) %>% as.character()
  ) %>%
  select(-redcap_event_name)

# derive measurements (average of three taken at each assessment)
animo <- animo %>%
  rowwise() %>%
  mutate(weight_3_paf = as.numeric(weight_3_paf),
         weight_3_paf_mini = as.numeric(weight_3_paf_mini),
         weight = mean(c(weight_1_paf,
                         weight_2_paf,
                         weight_3_paf,
                         weight_1_paf_mini,
                         weight_2_paf_mini,
                         weight_3_paf_mini), na.rm = T),
         waist = mean(c(waist_1_paf, waist_2_paf, waist_3_paf), na.rm = T)
  ) %>% ungroup()

# subset to occasions and variables of interest
animo <- animo %>% filter(week %in% c(0, 12, 24), !is.na(group)) %>%
  select(participant_id, week, group, weight, waist, ends_with('gpaq'))


# clean physical activity data --------------------------------------------

animo <- animo %>%
  mutate_at(vars(starts_with("time")), funs(parse_number)) %>%
  mutate(
    vigorous_PA_minutes = days_vig_rec_gpaq *
      (time_vig_rec_h_gpaq * 60 + time_vig_rec_min_gpaq),
    vigorous_PA_minutes = ifelse(vig_rec_gpaq == "No",
                                 0,
                                 vigorous_PA_minutes),
    moderate_PA_minutes = days_mod_rec_gpaq *
      (time_mod_rec_h_gpaq * 60 + time_mod_rec_min_gpaq),
    moderate_PA_minutes = ifelse(mod_rec_gpaq == "No",
                                 0,
                                 vigorous_PA_minutes),
    total_PA_minutes = vigorous_PA_minutes + moderate_PA_minutes
  ) %>% select(-ends_with('gpaq'))


# clean food data ---------------------------------------------------------

food <- map2_df(
  list(food_base, food_week_12, food_week_24),
  c("0", "12", "24"),
  ~ .x %>% select(sid, kcals_per_day = ener) %>%
    mutate(sid = parse_number(sid),
           participant_id = ifelse(sid < 10,
                                   paste0("HMS3-00", sid),
                                   paste0("HMS3-0", sid)),
           week = .y) # %>% select(participant_id, week, kcals_per_day, -sid)
) %>% select(-sid)


# clean blood data --------------------------------------------------------

blood_labels <- tibble(
  hba1c = "Glycated.Hemoglobin",
  alt = "ALT",
  ast = "AST",
  cholesterol = "Cholesterol",
  hdl = "HDL.Cholesterol",
  ldl = "LDL.Cholesterol",
  triglycerides = "Triglycerides",
  hscrp = "hs.CRP"
)

variable_labels_blood  <- c(
  map_chr(blood_labels, ~ .x),
  map_chr(blood_labels, ~  paste0(.x, '.1')),
  map_chr(blood_labels, ~  paste0(.x, '.2'))
)

variable_names_blood <- c(
  names(blood_labels),
  paste0(names(blood_labels), '.1'),
  paste0(names(blood_labels), '.2')
)

# select variables of interest, set variable names
blood <- blood %>% select(Record.ID, one_of(variable_labels_blood)) %>%
  set_names(c('participant_id', variable_names_blood))

# fix wrong id
blood <- blood %>%
  mutate(participant_id = ifelse(participant_id == 'HMS-023',
                                 'HMS3-023',
                                 participant_id))

# select variables of interest, set variable names
blood <- blood %>%
  gather(key, value, -participant_id) %>%
  separate(key, c('var', 'week'), convert = T) %>%
  spread(key = var, value = value, convert = T)

# change weeks to be correct
blood <- blood %>%
  mutate(week = ifelse(is.na(week), 0, week),
         week = as.character(week * 12))

# reset lables to be pretty for output
blood_labels <- tibble(
  hba1c = "HbA1c",
  alt = "ALT",
  ast = "AST",
  cholesterol = "Total Cholesterol",
  hdl = "HDL Cholesterol",
  ldl = "LDL Cholesterol",
  triglycerides = "Triglycerides",
  hscrp = "hs-CRP"
)


# clean dxa data ----------------------------------------------------------

dxa <- dxa %>%
  rename(participant_id = patient_id,
         week = `time point`,
         pct_fat = TB_tissue_pfat) %>%
  mutate(week = as.character((week - 1) * 12))


# join all data -----------------------------------------------------------

animo <- full_join(animo, dxa, by = c("participant_id", "week")) %>%
  full_join(blood, by = c("participant_id", "week")) %>%
  full_join(food, by = c("participant_id", "week"))


# remove participants who weren’t randomized ------------------------------

animo <- animo %>%
  group_by(participant_id) %>%
  mutate(group = group[1]) %>%
  ungroup() %>%
  filter(!is.na(group))


# relabel groups ----------------------------------------------------------

animo <- animo %>%
  mutate(group = factor(group, 0:1, c("WLC", "GCSWLI")),
         week = factor(week, c(0, 12, 24)))

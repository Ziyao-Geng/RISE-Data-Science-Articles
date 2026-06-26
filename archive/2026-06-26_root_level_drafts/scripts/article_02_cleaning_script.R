library(tidyverse)
library(janitor)

missing_codes <- c("", "NA", "Unknown", "Not recorded", "999", "-99")

health_raw <- read_csv(
  "data/rise_sample_health_data_messy.csv",
  na = missing_codes
)

health_clean <- health_raw %>%
  clean_names()

head(health_clean)
glimpse(health_clean)
summary(health_clean)

health_clean %>%
  summarise(across(everything(), ~ sum(is.na(.))))

health_clean <- health_clean %>%
  mutate(
    sex = case_when(
      str_to_lower(sex) %in% c("m", "male") ~ "Male",
      str_to_lower(sex) %in% c("f", "female") ~ "Female",
      TRUE ~ NA_character_
    ),
    smoking_status = str_to_lower(smoking_status),
    smoking_status = str_replace_all(smoking_status, "-", " "),
    smoking_status = case_when(
      smoking_status %in% c("never", "never smoker", "non smoker", "nonsmoker") ~ "Never",
      smoking_status %in% c("ex", "former", "former smoker") ~ "Former",
      smoking_status %in% c("current", "current smoker") ~ "Current",
      TRUE ~ NA_character_
    ),
    age_flag = !is.na(age) & (age < 0 | age > 120),
    bmi_flag = !is.na(bmi) & (bmi < 10 | bmi > 80),
    systolic_bp_flag = !is.na(systolic_bp) & (systolic_bp < 60 | systolic_bp > 250),
    diastolic_bp_flag = !is.na(diastolic_bp) & (diastolic_bp < 30 | diastolic_bp > 150),
    hba1c_flag = !is.na(hb_a1c_mmol_mol) & (hb_a1c_mmol_mol < 20 | hb_a1c_mmol_mol > 130),
    bmi_category = case_when(
      is.na(bmi) ~ NA_character_,
      bmi < 18.5 ~ "Underweight",
      bmi >= 18.5 & bmi < 25 ~ "Healthy weight",
      bmi >= 25 & bmi < 30 ~ "Overweight",
      bmi >= 30 ~ "Obesity"
    ),
    hba1c_group = case_when(
      is.na(hb_a1c_mmol_mol) ~ NA_character_,
      hb_a1c_mmol_mol < 42 ~ "Below diabetes threshold",
      hb_a1c_mmol_mol >= 42 & hb_a1c_mmol_mol < 48 ~ "Increased risk range",
      hb_a1c_mmol_mol >= 48 ~ "Diabetes range"
    )
  )

tabyl(health_clean$sex)
tabyl(health_clean$smoking_status)
tabyl(health_clean$bmi_category)

health_clean %>%
  filter(age_flag | bmi_flag | systolic_bp_flag | diastolic_bp_flag | hba1c_flag) %>%
  select(
    participant_id,
    age,
    bmi,
    systolic_bp,
    diastolic_bp,
    hb_a1c_mmol_mol,
    ends_with("flag")
  )

duplicate_ids <- health_clean %>%
  count(participant_id) %>%
  filter(n > 1)

duplicate_ids

health_clean %>%
  semi_join(duplicate_ids, by = "participant_id") %>%
  arrange(participant_id)

health_clean %>%
  group_by(diabetes_status) %>%
  summarise(
    n = n(),
    mean_age = mean(age, na.rm = TRUE),
    median_age = median(age, na.rm = TRUE),
    mean_bmi = mean(bmi, na.rm = TRUE),
    median_bmi = median(bmi, na.rm = TRUE)
  )

write_csv(health_clean, "data/rise_sample_health_data_cleaned.csv")

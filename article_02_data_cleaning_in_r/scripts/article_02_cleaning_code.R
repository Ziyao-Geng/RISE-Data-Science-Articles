# RISE Article 2: Cleaning Clinical Research Data in R
# ----------------------------------------------------
# This script reproduces the data cleaning workflow from Article 2.

library(tidyverse)
library(janitor)

dir.create("data_cleaned", showWarnings = FALSE)
dir.create("outputs", showWarnings = FALSE)

# Import raw data as character to avoid premature type guessing.
raw_data_path <- "data_raw/rise_sample_health_data_messy.csv"

if (!file.exists(raw_data_path)) {
  stop("Cannot find the raw dataset. Check that it is inside the data_raw/ folder.")
}

raw_data <- read_csv(
  file = raw_data_path,
  col_types = cols(.default = col_character()),
  na = c("", "NA", "N/A", "Unknown", "Not recorded", "not available")
)

# Missing values before cleaning.
missing_before_cleaning <- raw_data %>%
  summarise(across(everything(), ~ sum(is.na(.x)))) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "missing_n") %>%
  arrange(desc(missing_n))

# Clean column names and standardise HbA1c name.
clean_data <- raw_data %>%
  clean_names() %>%
  rename_with(~ str_replace(.x, "^hb_a1c_mmol_mol$", "hba1c_mmol_mol"))

# Clean participant IDs and whitespace.
clean_data <- clean_data %>%
  mutate(
    participant_id = str_squish(participant_id),
    participant_id = str_to_upper(participant_id),
    across(where(is.character), str_squish)
  )

# Duplicate report.
duplicate_participants <- clean_data %>%
  count(participant_id, name = "n_rows") %>%
  filter(n_rows > 1)

write_csv(duplicate_participants, "outputs/duplicate_participant_report.csv")

n_before_duplicates <- nrow(clean_data)

clean_data <- clean_data %>%
  distinct(participant_id, .keep_all = TRUE)

n_after_duplicates <- nrow(clean_data)

# Convert numeric variables.
clean_data <- clean_data %>%
  mutate(
    age = parse_number(age),
    bmi = parse_number(bmi),
    systolic_bp = parse_number(systolic_bp),
    diastolic_bp = parse_number(diastolic_bp),
    hba1c_mmol_mol = parse_number(hba1c_mmol_mol),
    exercise_minutes_per_week = parse_number(exercise_minutes_per_week)
  )

# Standardise categorical variables.
clean_data <- clean_data %>%
  mutate(
    sex = str_to_lower(sex),
    sex = case_when(
      sex %in% c("male", "m", "man") ~ "Male",
      sex %in% c("female", "f", "woman") ~ "Female",
      TRUE ~ NA_character_
    ),
    diabetes_status = str_to_lower(diabetes_status),
    diabetes_status = case_when(
      diabetes_status %in% c("yes", "y", "t2dm", "type 2 diabetes", "diabetes") ~ "Yes",
      diabetes_status %in% c("no", "n", "no diabetes") ~ "No",
      TRUE ~ NA_character_
    ),
    smoking_status = str_to_lower(smoking_status),
    smoking_status = case_when(
      smoking_status %in% c("never", "n", "never smoker") ~ "Never",
      smoking_status %in% c("former", "ex-smoker", "past smoker") ~ "Former",
      smoking_status %in% c("current", "c", "smoker") ~ "Current",
      TRUE ~ NA_character_
    ),
    recruitment_site = str_to_title(recruitment_site),
    study_group = str_to_title(study_group)
  )

# Suspicious value report.
suspicious_values <- bind_rows(
  clean_data %>% filter(age < 0 | age > 120) %>% transmute(participant_id, variable = "age", value = as.character(age), reason = "Age outside 0-120"),
  clean_data %>% filter(bmi < 10 | bmi > 80) %>% transmute(participant_id, variable = "bmi", value = as.character(bmi), reason = "BMI outside 10-80"),
  clean_data %>% filter(systolic_bp < 70 | systolic_bp > 250) %>% transmute(participant_id, variable = "systolic_bp", value = as.character(systolic_bp), reason = "Systolic BP outside 70-250"),
  clean_data %>% filter(diastolic_bp < 40 | diastolic_bp > 150) %>% transmute(participant_id, variable = "diastolic_bp", value = as.character(diastolic_bp), reason = "Diastolic BP outside 40-150"),
  clean_data %>% filter(hba1c_mmol_mol < 15 | hba1c_mmol_mol > 160) %>% transmute(participant_id, variable = "hba1c_mmol_mol", value = as.character(hba1c_mmol_mol), reason = "HbA1c outside 15-160"),
  clean_data %>% filter(exercise_minutes_per_week < 0 | exercise_minutes_per_week > 2000) %>% transmute(participant_id, variable = "exercise_minutes_per_week", value = as.character(exercise_minutes_per_week), reason = "Exercise minutes outside 0-2000")
)

write_csv(suspicious_values, "outputs/suspicious_values_report.csv")

# Replace impossible values with NA.
clean_data <- clean_data %>%
  mutate(
    age = if_else(age < 0 | age > 120, NA_real_, age),
    bmi = if_else(bmi < 10 | bmi > 80, NA_real_, bmi),
    systolic_bp = if_else(systolic_bp < 70 | systolic_bp > 250, NA_real_, systolic_bp),
    diastolic_bp = if_else(diastolic_bp < 40 | diastolic_bp > 150, NA_real_, diastolic_bp),
    hba1c_mmol_mol = if_else(hba1c_mmol_mol < 15 | hba1c_mmol_mol > 160, NA_real_, hba1c_mmol_mol),
    exercise_minutes_per_week = if_else(exercise_minutes_per_week < 0 | exercise_minutes_per_week > 2000, NA_real_, exercise_minutes_per_week)
  )

# Missing values after cleaning.
missing_after_cleaning <- clean_data %>%
  summarise(across(everything(), ~ sum(is.na(.x)))) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "missing_n") %>%
  arrange(desc(missing_n))

write_csv(missing_after_cleaning, "outputs/missing_value_summary.csv")

# Cleaning summary.
data_cleaning_summary <- tibble(
  cleaning_step = c("Raw dataset", "Before removing duplicate participant IDs", "After removing duplicate participant IDs", "Final cleaned dataset"),
  n_rows = c(nrow(raw_data), n_before_duplicates, n_after_duplicates, nrow(clean_data))
)

write_csv(data_cleaning_summary, "outputs/data_cleaning_summary.csv")

# Variable dictionary.
variable_dictionary <- tribble(
  ~variable, ~description, ~type, ~cleaning_note,
  "participant_id", "Unique fictional participant identifier", "Identifier", "Cleaned to uppercase and stripped of extra spaces",
  "age", "Age in years", "Continuous numeric", "Values outside 0-120 replaced with missing",
  "sex", "Sex recorded in the dataset", "Categorical", "Standardised to Male/Female; unclear values set to missing",
  "bmi", "Body mass index in kg/m^2", "Continuous numeric", "Values outside 10-80 replaced with missing",
  "systolic_bp", "Systolic blood pressure in mmHg", "Continuous numeric", "Values outside 70-250 replaced with missing",
  "diastolic_bp", "Diastolic blood pressure in mmHg", "Continuous numeric", "Values outside 40-150 replaced with missing",
  "hba1c_mmol_mol", "HbA1c in mmol/mol", "Continuous numeric", "Values outside 15-160 replaced with missing",
  "smoking_status", "Smoking history", "Categorical", "Standardised to Never/Former/Current",
  "diabetes_status", "Diabetes status", "Binary categorical", "Standardised to Yes/No",
  "recruitment_site", "Fictional recruitment location", "Categorical", "Converted to title case",
  "study_group", "Fictional study group", "Categorical", "Converted to title case",
  "exercise_minutes_per_week", "Self-reported exercise minutes per week", "Continuous numeric", "Values outside 0-2000 replaced with missing"
)

write_csv(variable_dictionary, "outputs/variable_dictionary.csv")

# Save final cleaned dataset.
write_csv(clean_data, "data_cleaned/rise_sample_health_data_cleaned.csv")

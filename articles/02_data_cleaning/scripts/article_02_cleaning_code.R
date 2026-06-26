# ============================================================
# RISE Article 02
# Cleaning Clinical Research Data in R
# ============================================================
# Purpose:
# This script cleans a deliberately messy fictional health dataset.
# It is designed for beginners who are learning how to move from
# raw spreadsheet data to an analysis-ready dataset.
#
# Main principles:
# 1. Keep the raw data untouched.
# 2. Write cleaning steps in code.
# 3. Save a cleaned dataset separately.
# 4. Save simple reports that document what was cleaned.
# ============================================================

# -----------------------------
# 1. Load packages
# -----------------------------
# Install these packages first if needed:
# install.packages("tidyverse")
# install.packages("janitor")

library(tidyverse)
library(janitor)

# -----------------------------
# 2. Create output folders
# -----------------------------
dir.create("data_cleaned", showWarnings = FALSE)
dir.create("outputs", showWarnings = FALSE)

# -----------------------------
# 3. Import raw data
# -----------------------------
raw_data_path <- "data_raw/rise_sample_health_data_messy.csv"

if (!file.exists(raw_data_path)) {
  stop("Cannot find the raw dataset. Check that it is inside the data_raw/ folder.")
}

raw_data <- read_csv(
  file = raw_data_path,
  col_types = cols(.default = col_character()),
  na = c("", "NA", "N/A", "Unknown", "Not recorded", "not available")
)

# -----------------------------
# 4. Inspect raw data
# -----------------------------
head(raw_data)
glimpse(raw_data)
dim(raw_data)
names(raw_data)

missing_before_cleaning <- raw_data %>%
  summarise(across(everything(), ~ sum(is.na(.x)))) %>%
  pivot_longer(
    cols = everything(),
    names_to = "variable",
    values_to = "missing_n"
  ) %>%
  arrange(desc(missing_n))

missing_before_cleaning

# -----------------------------
# 5. Clean column names and text spacing
# -----------------------------
clean_data <- raw_data %>%
  clean_names() %>%
  mutate(
    participant_id = str_squish(participant_id),
    participant_id = str_to_upper(participant_id),
    across(where(is.character), str_squish)
  )

names(clean_data)

# -----------------------------
# 6. Find duplicate participant IDs
# -----------------------------
duplicate_participants <- clean_data %>%
  count(participant_id, name = "n_rows") %>%
  filter(n_rows > 1)

duplicate_participants

# In this teaching dataset, each row should represent one participant.
# Therefore, we keep one row per participant ID.
# In real research, check duplicates carefully before removing them.
clean_data <- clean_data %>%
  distinct(participant_id, .keep_all = TRUE)

# -----------------------------
# 7. Convert numeric variables
# -----------------------------
# parse_number() extracts numbers from text such as "142 mmHg".
clean_data <- clean_data %>%
  mutate(
    age = parse_number(age),
    bmi = parse_number(bmi),
    systolic_bp = parse_number(systolic_bp),
    diastolic_bp = parse_number(diastolic_bp),
    hba1c_mmol_mol = parse_number(hba1c_mmol_mol),
    exercise_minutes_per_week = parse_number(exercise_minutes_per_week)
  )

glimpse(clean_data)

# -----------------------------
# 8. Standardise categorical variables
# -----------------------------
clean_data <- clean_data %>%
  mutate(
    sex = str_to_lower(sex),
    sex = case_when(
      sex %in% c("male", "m", "man") ~ "Male",
      sex %in% c("female", "f", "woman") ~ "Female",
      TRUE ~ NA_character_
    ),

    smoking_status = str_to_lower(smoking_status),
    smoking_status = case_when(
      smoking_status %in% c("never", "never smoker", "n") ~ "Never",
      smoking_status %in% c("former", "ex-smoker", "ex smoker", "f", "quit") ~ "Former",
      smoking_status %in% c("current", "current smoker", "c") ~ "Current",
      TRUE ~ NA_character_
    ),

    diabetes_status = str_to_lower(diabetes_status),
    diabetes_status = case_when(
      diabetes_status %in% c("yes", "y", "t2dm", "type 2 diabetes") ~ "Yes",
      diabetes_status %in% c("no", "n", "no diabetes") ~ "No",
      TRUE ~ NA_character_
    ),

    study_group = str_to_lower(study_group),
    study_group = case_when(
      study_group %in% c("control", "c") ~ "Control",
      study_group %in% c("intervention", "i") ~ "Intervention",
      TRUE ~ NA_character_
    ),

    recruitment_site = str_to_lower(recruitment_site),
    recruitment_site = case_when(
      recruitment_site == "rpa" ~ "RPA",
      recruitment_site == "westmead" ~ "Westmead",
      recruitment_site == "concord" ~ "Concord",
      recruitment_site == "royal north shore" ~ "Royal North Shore",
      TRUE ~ NA_character_
    )
  )

clean_data %>% count(sex)
clean_data %>% count(smoking_status)
clean_data %>% count(diabetes_status)
clean_data %>% count(study_group)
clean_data %>% count(recruitment_site)

# -----------------------------
# 9. Create suspicious value report
# -----------------------------
suspicious_values <- bind_rows(
  clean_data %>% filter(age < 0) %>% transmute(participant_id, variable = "age", value = as.character(age), issue = "Age is below 0 years"),
  clean_data %>% filter(age > 120) %>% transmute(participant_id, variable = "age", value = as.character(age), issue = "Age is above 120 years"),
  clean_data %>% filter(bmi < 10) %>% transmute(participant_id, variable = "bmi", value = as.character(bmi), issue = "BMI is below 10 kg/m^2"),
  clean_data %>% filter(bmi > 80) %>% transmute(participant_id, variable = "bmi", value = as.character(bmi), issue = "BMI is above 80 kg/m^2"),
  clean_data %>% filter(systolic_bp < 70) %>% transmute(participant_id, variable = "systolic_bp", value = as.character(systolic_bp), issue = "Systolic BP is below 70 mmHg"),
  clean_data %>% filter(systolic_bp > 250) %>% transmute(participant_id, variable = "systolic_bp", value = as.character(systolic_bp), issue = "Systolic BP is above 250 mmHg"),
  clean_data %>% filter(diastolic_bp < 40) %>% transmute(participant_id, variable = "diastolic_bp", value = as.character(diastolic_bp), issue = "Diastolic BP is below 40 mmHg"),
  clean_data %>% filter(diastolic_bp > 150) %>% transmute(participant_id, variable = "diastolic_bp", value = as.character(diastolic_bp), issue = "Diastolic BP is above 150 mmHg"),
  clean_data %>% filter(hba1c_mmol_mol < 15) %>% transmute(participant_id, variable = "hba1c_mmol_mol", value = as.character(hba1c_mmol_mol), issue = "HbA1c is below 15 mmol/mol"),
  clean_data %>% filter(hba1c_mmol_mol > 160) %>% transmute(participant_id, variable = "hba1c_mmol_mol", value = as.character(hba1c_mmol_mol), issue = "HbA1c is above 160 mmol/mol"),
  clean_data %>% filter(exercise_minutes_per_week < 0) %>% transmute(participant_id, variable = "exercise_minutes_per_week", value = as.character(exercise_minutes_per_week), issue = "Exercise minutes are below 0"),
  clean_data %>% filter(exercise_minutes_per_week > 2000) %>% transmute(participant_id, variable = "exercise_minutes_per_week", value = as.character(exercise_minutes_per_week), issue = "Exercise minutes are above 2000 per week")
)

suspicious_values

# -----------------------------
# 10. Replace impossible values with missing values
# -----------------------------
clean_data <- clean_data %>%
  mutate(
    age = if_else(age < 0 | age > 120, NA_real_, age),
    bmi = if_else(bmi < 10 | bmi > 80, NA_real_, bmi),
    systolic_bp = if_else(systolic_bp < 70 | systolic_bp > 250, NA_real_, systolic_bp),
    diastolic_bp = if_else(diastolic_bp < 40 | diastolic_bp > 150, NA_real_, diastolic_bp),
    hba1c_mmol_mol = if_else(hba1c_mmol_mol < 15 | hba1c_mmol_mol > 160, NA_real_, hba1c_mmol_mol),
    exercise_minutes_per_week = if_else(exercise_minutes_per_week < 0 | exercise_minutes_per_week > 2000, NA_real_, exercise_minutes_per_week)
  )

# -----------------------------
# 11. Missing value summary after cleaning
# -----------------------------
missing_after_cleaning <- clean_data %>%
  summarise(across(everything(), ~ sum(is.na(.x)))) %>%
  pivot_longer(
    cols = everything(),
    names_to = "variable",
    values_to = "missing_n"
  ) %>%
  mutate(
    missing_percent = round(missing_n / nrow(clean_data) * 100, 1)
  ) %>%
  arrange(desc(missing_n))

missing_after_cleaning

# -----------------------------
# 12. Cleaning summary
# -----------------------------
data_cleaning_summary <- tibble(
  step = c(
    "Raw dataset",
    "After removing duplicate participants",
    "After cleaning impossible values"
  ),
  number_of_rows = c(
    nrow(raw_data),
    nrow(clean_data),
    nrow(clean_data)
  ),
  number_of_columns = c(
    ncol(raw_data),
    ncol(clean_data),
    ncol(clean_data)
  ),
  note = c(
    "Original dataset exactly as imported from the CSV file",
    "One row kept for each unique participant_id",
    "Extreme or impossible values replaced with missing values"
  )
)

data_cleaning_summary


# -----------------------------
# 13. Create a variable dictionary
# -----------------------------
variable_dictionary <- tribble(
  ~variable, ~description, ~type, ~cleaning_note,
  "participant_id", "Unique fictional participant identifier", "Text/categorical", "Cleaned to uppercase and stripped of extra spaces",
  "age", "Age in years", "Continuous numeric", "Implausible values outside 0-120 replaced with missing",
  "sex", "Sex recorded in the sample data", "Categorical", "Standardised to Male/Female; unclear values set to missing",
  "bmi", "Body mass index in kg/m^2", "Continuous numeric", "Implausible values outside 10-80 replaced with missing",
  "systolic_bp", "Systolic blood pressure in mmHg", "Continuous numeric", "Implausible values outside 70-250 replaced with missing",
  "diastolic_bp", "Diastolic blood pressure in mmHg", "Continuous numeric", "Implausible values outside 40-150 replaced with missing",
  "hba1c_mmol_mol", "HbA1c in mmol/mol", "Continuous numeric", "Parsed into numeric; very extreme values would be set to missing",
  "smoking_status", "Smoking status", "Categorical", "Standardised to Never/Former/Current",
  "exercise_minutes_per_week", "Self-reported exercise minutes per week", "Continuous numeric", "Negative or extreme values replaced with missing",
  "diabetes_status", "Recorded diabetes status", "Binary categorical", "Standardised to Yes/No; unclear values set to missing",
  "study_group", "Fictional study group", "Categorical", "Standardised to Control/Intervention",
  "recruitment_site", "Fictional recruitment site", "Categorical", "Standardised site names",
  "notes", "Free-text notes", "Text", "Kept as text; not used for analysis in this article"
)

variable_dictionary

# -----------------------------
# 14. Save cleaned data and reports
# -----------------------------
write_csv(clean_data, "data_cleaned/rise_sample_health_data_cleaned.csv")
write_csv(duplicate_participants, "outputs/duplicate_participant_report.csv")
write_csv(suspicious_values, "outputs/suspicious_values_report.csv")
write_csv(missing_after_cleaning, "outputs/missing_value_summary.csv")
write_csv(data_cleaning_summary, "outputs/data_cleaning_summary.csv")
write_csv(variable_dictionary, "outputs/variable_dictionary.csv")

# -----------------------------
# 15. Final quick checks
# -----------------------------
glimpse(clean_data)
summary(clean_data)

clean_data %>% tabyl(sex)
clean_data %>% tabyl(smoking_status)
clean_data %>% tabyl(diabetes_status)

clean_data %>%
  summarise(
    n = n(),
    mean_age = mean(age, na.rm = TRUE),
    median_bmi = median(bmi, na.rm = TRUE),
    mean_systolic_bp = mean(systolic_bp, na.rm = TRUE),
    median_hba1c = median(hba1c_mmol_mol, na.rm = TRUE)
  )

# Optional quick plots
# These are useful for checking whether the cleaned data look reasonable.
ggplot(clean_data, aes(x = bmi)) +
  geom_histogram(binwidth = 2, colour = "white") +
  labs(
    title = "Distribution of BMI after cleaning",
    x = "BMI",
    y = "Number of participants"
  )

ggplot(clean_data, aes(x = diabetes_status, y = bmi)) +
  geom_boxplot() +
  labs(
    title = "BMI by diabetes status after cleaning",
    x = "Diabetes status",
    y = "BMI"
  )

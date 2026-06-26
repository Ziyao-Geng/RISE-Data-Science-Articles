# article_01_starter_code.R
# Getting Started with R for Medical Research
# RISE Education Team
#
# This script contains the main R code used in the beginner article.
# Run it line by line in RStudio.

# ------------------------------------------------------------
# 1. Load packages
# ------------------------------------------------------------

# Install these packages once if needed:
# install.packages("tidyverse")
# install.packages("janitor")

library(tidyverse)
library(janitor)

# ------------------------------------------------------------
# 2. Import data
# ------------------------------------------------------------

# Store the file path in one object.
data_path <- "data/rise_sample_health_data.csv"

# Check that the file exists before importing it.
if (!file.exists(data_path)) {
  stop("Cannot find the dataset. Check that rise_sample_health_data.csv is inside the data/ folder.")
}

# Import the CSV file.
health_data <- read_csv(data_path, show_col_types = FALSE)

# ------------------------------------------------------------
# 3. Clean column names
# ------------------------------------------------------------

health_data <- health_data %>%
  clean_names()

names(health_data)

# ------------------------------------------------------------
# 4. Inspect the dataset
# ------------------------------------------------------------

head(health_data)
glimpse(health_data)
summary(health_data)

nrow(health_data)
ncol(health_data)
dim(health_data)

# ------------------------------------------------------------
# 5. Check missing values
# ------------------------------------------------------------

colSums(is.na(health_data))

missing_summary <- health_data %>%
  summarise(across(everything(), ~ sum(is.na(.x)))) %>%
  pivot_longer(
    cols = everything(),
    names_to = "variable",
    values_to = "n_missing"
  ) %>%
  arrange(desc(n_missing))

missing_summary

# ------------------------------------------------------------
# 6. Simple summaries
# ------------------------------------------------------------

mean(health_data$age, na.rm = TRUE)
median(health_data$bmi, na.rm = TRUE)
range(health_data$systolic_bp, na.rm = TRUE)

health_data %>%
  count(sex)

health_data %>%
  count(smoking_status)

health_data %>%
  count(diabetes_status)

health_data %>%
  group_by(diabetes_status) %>%
  summarise(
    n = n(),
    mean_bmi = mean(bmi, na.rm = TRUE),
    median_bmi = median(bmi, na.rm = TRUE),
    mean_hba1c = mean(hba1c_mmol_mol, na.rm = TRUE),
    .groups = "drop"
  )

# ------------------------------------------------------------
# 7. Plots
# ------------------------------------------------------------

# Histogram of BMI
ggplot(data = health_data, aes(x = bmi)) +
  geom_histogram(binwidth = 2, colour = "white") +
  labs(
    title = "Distribution of BMI",
    x = "BMI",
    y = "Number of participants"
  ) +
  theme_minimal()

# Boxplot of BMI by diabetes status
ggplot(data = health_data, aes(x = diabetes_status, y = bmi)) +
  geom_boxplot() +
  labs(
    title = "BMI by diabetes status",
    x = "Diabetes status",
    y = "BMI"
  ) +
  theme_minimal()

# Scatterplot of BMI and HbA1c
ggplot(data = health_data, aes(x = bmi, y = hba1c_mmol_mol)) +
  geom_point() +
  labs(
    title = "BMI and HbA1c",
    x = "BMI",
    y = "HbA1c (mmol/mol)"
  ) +
  theme_minimal()

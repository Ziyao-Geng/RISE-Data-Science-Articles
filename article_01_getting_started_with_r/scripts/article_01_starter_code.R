# RISE Article 1: Getting Started with R for Medical Research
# ------------------------------------------------------------
# This script contains the core code from Article 1.

library(tidyverse)

# Import the clean teaching dataset.
data_path <- "data/rise_sample_health_data.csv"

if (!file.exists(data_path)) {
  stop("Cannot find the dataset. Check that rise_sample_health_data.csv is inside the data/ folder.")
}

health_data <- read_csv(data_path, show_col_types = FALSE)

# Inspect the dataset.
head(health_data)
glimpse(health_data)
nrow(health_data)
ncol(health_data)
dim(health_data)
names(health_data)
summary(health_data)

# Basic summaries.
mean(health_data$age, na.rm = TRUE)
median(health_data$bmi, na.rm = TRUE)
range(health_data$systolic_bp, na.rm = TRUE)

health_data %>% count(sex)
health_data %>% count(diabetes_status)

# Simple plots.
ggplot(health_data, aes(x = bmi)) +
  geom_histogram(binwidth = 2, colour = "white") +
  labs(
    title = "Distribution of BMI",
    x = "BMI",
    y = "Number of participants"
  ) +
  theme_minimal()

ggplot(health_data, aes(x = diabetes_status, y = bmi)) +
  geom_boxplot() +
  labs(
    title = "BMI by diabetes status",
    x = "Diabetes status",
    y = "BMI"
  ) +
  theme_minimal()

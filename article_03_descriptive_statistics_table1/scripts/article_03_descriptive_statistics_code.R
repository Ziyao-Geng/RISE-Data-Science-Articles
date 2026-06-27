# RISE Article 3: Descriptive Statistics and Table 1 in R
# -------------------------------------------------------

library(tidyverse)
library(janitor)

dir.create("outputs", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)

clean_data <- read_csv("data/rise_sample_health_data_cleaned.csv", show_col_types = FALSE)

continuous_vars <- c("age", "bmi", "systolic_bp", "diastolic_bp", "hba1c_mmol_mol", "exercise_minutes_per_week")
categorical_vars <- c("sex", "smoking_status", "diabetes_status", "recruitment_site", "study_group")

# Missing values.
missing_summary <- clean_data %>%
  summarise(across(everything(), ~ sum(is.na(.x)))) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "missing_n") %>%
  arrange(desc(missing_n))
write_csv(missing_summary, "outputs/article_03_missing_summary.csv")

# Continuous summaries.
continuous_summary <- clean_data %>%
  summarise(
    across(
      all_of(continuous_vars),
      list(
        n = ~ sum(!is.na(.x)),
        mean = ~ mean(.x, na.rm = TRUE),
        sd = ~ sd(.x, na.rm = TRUE),
        median = ~ median(.x, na.rm = TRUE),
        q1 = ~ quantile(.x, 0.25, na.rm = TRUE),
        q3 = ~ quantile(.x, 0.75, na.rm = TRUE),
        min = ~ min(.x, na.rm = TRUE),
        max = ~ max(.x, na.rm = TRUE)
      ),
      .names = "{.col}_{.fn}"
    )
  ) %>%
  pivot_longer(
    everything(),
    names_to = c("variable", ".value"),
    names_pattern = "(.*)_(n|mean|sd|median|q1|q3|min|max)$"
  ) %>%
  mutate(across(where(is.numeric), ~ round(.x, 1)))
write_csv(continuous_summary, "outputs/article_03_continuous_summary.csv")

# Categorical summaries.
categorical_summary <- clean_data %>%
  select(all_of(categorical_vars)) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "category") %>%
  filter(!is.na(category)) %>%
  count(variable, category, name = "n") %>%
  group_by(variable) %>%
  mutate(percent = round(100 * n / sum(n), 1), result = paste0(n, " (", percent, "%)")) %>%
  ungroup()
write_csv(categorical_summary, "outputs/article_03_categorical_summary.csv")

# Overall Table 1.
table1_continuous <- continuous_summary %>%
  transmute(variable, summary = paste0(median, " [", q1, ", ", q3, "]"), format = "Median [IQR]")
table1_categorical <- categorical_summary %>%
  transmute(variable = paste0(variable, ": ", category), summary = result, format = "n (%)")
table1_overall <- bind_rows(table1_continuous, table1_categorical)
write_csv(table1_overall, "outputs/article_03_table1_overall.csv")

# Table 1 by diabetes status.
table1_by_diabetes_continuous <- clean_data %>%
  group_by(diabetes_status) %>%
  summarise(
    across(
      all_of(continuous_vars),
      list(median = ~ median(.x, na.rm = TRUE), q1 = ~ quantile(.x, 0.25, na.rm = TRUE), q3 = ~ quantile(.x, 0.75, na.rm = TRUE)),
      .names = "{.col}_{.fn}"
    ),
    .groups = "drop"
  ) %>%
  pivot_longer(-diabetes_status, names_to = c("variable", ".value"), names_pattern = "(.*)_(median|q1|q3)$") %>%
  mutate(summary = paste0(round(median, 1), " [", round(q1, 1), ", ", round(q3, 1), "]")) %>%
  select(variable, diabetes_status, summary) %>%
  pivot_wider(names_from = diabetes_status, values_from = summary)

table1_by_diabetes_categorical <- clean_data %>%
  select(diabetes_status, all_of(categorical_vars)) %>%
  pivot_longer(cols = all_of(setdiff(categorical_vars, "diabetes_status")), names_to = "variable", values_to = "category") %>%
  filter(!is.na(category), !is.na(diabetes_status)) %>%
  count(diabetes_status, variable, category, name = "n") %>%
  group_by(diabetes_status, variable) %>%
  mutate(percent = round(100 * n / sum(n), 1), summary = paste0(n, " (", percent, "%)")) %>%
  ungroup() %>%
  mutate(variable = paste0(variable, ": ", category)) %>%
  select(variable, diabetes_status, summary) %>%
  pivot_wider(names_from = diabetes_status, values_from = summary)

table1_by_diabetes <- bind_rows(table1_by_diabetes_continuous, table1_by_diabetes_categorical)
write_csv(table1_by_diabetes, "outputs/article_03_table1_by_diabetes_status.csv")

# Plots.
bmi_plot <- ggplot(clean_data, aes(x = bmi)) +
  geom_histogram(binwidth = 2, colour = "white") +
  labs(title = "Distribution of BMI", x = "BMI", y = "Number of participants") +
  theme_minimal()
ggsave("figures/article_03_bmi_distribution.png", bmi_plot, width = 7, height = 5, dpi = 300)

hba1c_plot <- ggplot(clean_data, aes(x = diabetes_status, y = hba1c_mmol_mol)) +
  geom_boxplot() +
  geom_jitter(width = 0.15, alpha = 0.6) +
  labs(title = "HbA1c by diabetes status", x = "Diabetes status", y = "HbA1c (mmol/mol)") +
  theme_minimal()
ggsave("figures/article_03_hba1c_by_diabetes_status.png", hba1c_plot, width = 7, height = 5, dpi = 300)

# Simple tests.
bmi_t_test <- t.test(bmi ~ diabetes_status, data = clean_data)
bmi_t_test_summary <- tibble(comparison = "BMI by diabetes status", test = "Two-sample t-test", p_value = bmi_t_test$p.value)
write_csv(bmi_t_test_summary, "outputs/article_03_bmi_t_test_summary.csv")

sex_diabetes_table <- table(clean_data$sex, clean_data$diabetes_status)
sex_diabetes_chisq <- chisq.test(sex_diabetes_table)
sex_diabetes_chisq_summary <- tibble(comparison = "Sex by diabetes status", test = "Chi-square test", p_value = sex_diabetes_chisq$p.value)
write_csv(sex_diabetes_chisq_summary, "outputs/article_03_sex_diabetes_chisq_summary.csv")

analysis_summary <- bind_rows(bmi_t_test_summary, sex_diabetes_chisq_summary)
write_csv(analysis_summary, "outputs/article_03_simple_analysis_summary.csv")

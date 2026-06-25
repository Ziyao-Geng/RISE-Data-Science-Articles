library(tidyverse)
library(janitor)

health_data <- read_csv("data/rise_sample_health_data.csv")

head(health_data)
glimpse(health_data)
summary(health_data)

nrow(health_data)
ncol(health_data)
names(health_data)

health_data %>% count(sex)
health_data %>% count(smoking_status)

health_data %>%
  group_by(diabetes_status) %>%
  summarise(
    n = n(),
    mean_bmi = mean(bmi, na.rm = TRUE),
    median_bmi = median(bmi, na.rm = TRUE)
  )

ggplot(health_data, aes(x = bmi)) +
  geom_histogram(binwidth = 2, colour = "white") +
  labs(
    title = "Distribution of BMI",
    x = "BMI",
    y = "Number of participants"
  )

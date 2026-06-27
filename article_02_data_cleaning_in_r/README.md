# Article 2: Cleaning Clinical Research Data in R

This is the second article in the RISE beginner R series. Use it after Article 1, or use it on its own if you already know how to open an RStudio Project and run basic R code.

## What you will learn

- How to preserve a raw dataset.
- How to inspect missing values and column names.
- How to clean participant IDs and text values.
- How to check duplicate participants.
- How to convert numeric variables safely.
- How to recode categorical variables.
- How to identify suspicious values.
- How to save a cleaned dataset and cleaning reports.

## Open first

| File | Use this when you want to |
| --- | --- |
| [`article_02_cleaning_clinical_research_data.html`](article_02_cleaning_clinical_research_data.html) | Read the finished article in a browser. |
| [`article_02_cleaning_clinical_research_data.qmd`](article_02_cleaning_clinical_research_data.qmd) | Run, edit, or re-render the article in RStudio. |
| [`rise_article_02_data_cleaning_in_r.Rproj`](rise_article_02_data_cleaning_in_r.Rproj) | Open this folder as an RStudio Project. |
| [`scripts/article_02_cleaning_code.R`](scripts/article_02_cleaning_code.R) | Run the cleaning workflow without the article text. |

## Folder contents

| Path | What it contains |
| --- | --- |
| `data_raw/rise_sample_health_data_messy.csv` | Messy fictional teaching dataset used at the start of the article. |
| `data_cleaned/rise_sample_health_data_cleaned.csv` | Cleaned dataset created by the cleaning workflow. |
| `outputs/` | Cleaning summaries, missing-value reports, duplicate checks, suspicious-value reports, and the variable dictionary. |
| `scripts/` | Standalone R script for the lesson code. |

## Which file should I use?

- Use `data_raw/` when learning how the cleaning workflow starts.
- Use `data_cleaned/` when you need the cleaned dataset for later analysis.
- Use `outputs/variable_dictionary.csv` when you need a quick explanation of the cleaned variables.

## How to run this article

Open the `.Rproj` file, then open the `.qmd` file and click **Render** in RStudio.

If you are working through the full sequence, go to [`../article_03_descriptive_statistics_table1`](../article_03_descriptive_statistics_table1/) next.

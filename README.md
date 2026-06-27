# RISE Data Science Articles

Beginner-friendly R and data science teaching articles for medical students and early clinical researchers.

This repository is organised as a short learning sequence. Each article is self-contained, so you can open one folder, read the article, run the code, and inspect the data used in that lesson.

## Start here

If you are new to R, work through the folders in order:

| Order | Folder | Main topic | Start with |
| --- | --- | --- | --- |
| 1 | [`article_01_getting_started_with_r`](article_01_getting_started_with_r/) | RStudio, Quarto, importing data, basic summaries, and first plots | [`article_01_getting_started_with_r.html`](article_01_getting_started_with_r/article_01_getting_started_with_r.html) |
| 2 | [`article_02_data_cleaning_in_r`](article_02_data_cleaning_in_r/) | Cleaning messy clinical research data into an analysis-ready dataset | [`article_02_cleaning_clinical_research_data.html`](article_02_data_cleaning_in_r/article_02_cleaning_clinical_research_data.html) |
| 3 | [`article_03_descriptive_statistics_table1`](article_03_descriptive_statistics_table1/) | Descriptive statistics, missingness summaries, Table 1, plots, and simple group comparisons | [`article_03_descriptive_statistics_and_table1.html`](article_03_descriptive_statistics_table1/article_03_descriptive_statistics_and_table1.html) |

For most students, the easiest path is:

1. Open the article folder.
2. Read the rendered `.html` file first.
3. Open the matching `.qmd` file in RStudio if you want to run or edit the code.
4. Use the `scripts/` folder if you want a clean standalone version of the code.
5. Check `data/`, `data_raw/`, `data_cleaned/`, `outputs/`, or `figures/` when the article refers to files.

## What the file types mean

| File or folder | What it is for |
| --- | --- |
| `README.md` | A plain-English guide to the folder you are in. Read this first. |
| `.html` | The rendered article. This is usually the best file to read in a browser. |
| `.qmd` | The Quarto source file. Open this in RStudio to run, edit, or re-render the article. |
| `.Rproj` | RStudio Project file. Open this to make paths and folders work smoothly. |
| `scripts/` | Standalone R scripts containing the main code from the article. |
| `data/` | Clean teaching data used directly by an article. |
| `data_raw/` | Raw or messy data before cleaning. Preserve this unchanged in real research. |
| `data_cleaned/` | Cleaned data created from raw data. |
| `outputs/` | CSV tables, checks, summaries, or reports created by the article code. |
| `figures/` | Plots created by the article code. |
| `images/` | Screenshots or supporting images used inside an article. |

## Software you need

Install these before running the articles locally:

- [R](https://cran.r-project.org/)
- [RStudio Desktop](https://posit.co/download/rstudio-desktop/)
- [Quarto](https://quarto.org/docs/get-started/)

The articles install or load R packages as needed. The main package used across the series is `tidyverse`.

## How to run an article

1. Download or clone this repository from GitHub.
2. Open the article folder you want.
3. Double-click the article-specific `.Rproj` file.
4. Open the `.qmd` file in RStudio.
5. Click **Render** to rebuild the `.html` article.

Each article folder is designed to work as its own small RStudio Project. This keeps the file paths beginner-friendly.

## Learning sequence

### Article 1: Getting Started with R for Medical Research

Use this first if you have never used R before. You will learn what R, RStudio, and Quarto are; how to run code; how to import a clean CSV; how to inspect a dataset; how to use simple pipes; and how to make first plots.

### Article 2: Cleaning Clinical Research Data in R

Use this after Article 1. You will start with a messy sample dataset and learn a reproducible cleaning workflow: preserve raw data, inspect missing values, clean column names, handle duplicates, convert variables, recode categories, check suspicious values, and save cleaned outputs.

### Article 3: Descriptive Statistics and Table 1 in R

Use this after Article 2. You will work with the cleaned dataset and learn how to summarise continuous and categorical variables, create a simple Table 1, compare groups carefully, export results, and create publication-style exploratory plots.

## Teaching data note

The datasets in this repository are fictional teaching datasets. They are intended for learning R and clinical research workflows. They should not be interpreted as real patient data or used for clinical decision-making.

## Repository map

```text
RISE Data Science Articles/
|-- README.md
|-- RISE Data Science Articles.Rproj
|-- article_01_getting_started_with_r/
|   |-- README.md
|   |-- article_01_getting_started_with_r.html
|   |-- article_01_getting_started_with_r.qmd
|   |-- data/
|   |-- images/
|   |-- outputs/
|   `-- scripts/
|-- article_02_data_cleaning_in_r/
|   |-- README.md
|   |-- article_02_cleaning_clinical_research_data.html
|   |-- article_02_cleaning_clinical_research_data.qmd
|   |-- data_raw/
|   |-- data_cleaned/
|   |-- outputs/
|   `-- scripts/
`-- article_03_descriptive_statistics_table1/
    |-- README.md
    |-- article_03_descriptive_statistics_and_table1.html
    |-- article_03_descriptive_statistics_and_table1.qmd
    |-- data/
    |-- figures/
    |-- outputs/
    `-- scripts/
```

## For educators or contributors

When updating an article, edit the `.qmd` source file first, render it to update the `.html`, and then check that any generated CSVs or figures still match the lesson. Keep article folders self-contained so that students can download only the folder they need.

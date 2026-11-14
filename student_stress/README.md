# Student Stress Analysis

## Summary
Exploratory and statistical analysis of student stress survey data — distributions,
correlations with mental stress level, group comparisons (gender, coping mechanisms),
stress categories, and association rules linking stress factors to coping strategies.
Companion notebooks cover a UK student survey dataset.

## Data & methodology
- Primary survey tables (`student_stress*.xlsx` / `.csv`) and UK survey workbook
- EDA: outliers, categorical profiles, correlation with `mental_stress_level`
- Inferential tests: t-test (gender), ANOVA + post-hoc (coping), category breakdowns
- Association rules on stress-related itemsets → coping mechanisms

## Limits & next steps
- Analysis complete in R Markdown; interactive dashboard shipped (`index.html` + optional Shiny `app.R`)
- Survey is self-reported; associations are not causal

## Tools
- R, R Markdown, tidyverse-style EDA, association-rule mining
- HTML / Chart.js dashboard; optional Shiny (`app.R`)

## Status
Complete

## Files
- `student_stress.rmd` — main stress analysis report
- `uk_student_survey.rmd`, `student_survey_ver2.rmd` — UK survey analyses
- Survey Excel / CSV inputs in this folder
- `index.html`, `style.css`, `dashboard_data.js` — static dashboard
- `app.R` — Shiny companion with gender/coping filters

## View dashboard
Open `index.html` in a browser, or run:
```r
shiny::runApp()
```


# Student Stress Analysis

## Summary
Exploratory and statistical analysis of student stress survey data — distributions,
correlations with mental stress level, group comparisons, stress categories, and
association rules. Companion UK survey notebooks included. Interactive dashboard
ships as static HTML (+ optional Shiny).

## Data & methodology
- Survey EDA, correlations, t-tests / ANOVA, association rules
- Dashboard reads local `student_stress.csv` (Shiny) or pre-baked `dashboard_data.js` (HTML)

## Data (not in git)
Keep survey tables locally (`student_stress.csv` / related `.xlsx`, UK survey workbook).

**Source:** Student stress survey extracts used for coursework analysis (self-reported
questionnaire items: study hours, sleep, coping, mental stress level, etc.). Cite your
original survey provider or assignment dataset page if publicly available.

## Limits & next steps
- Self-reported; associations are not causal
- HTML dashboard uses exported aggregates in `dashboard_data.js`

## Tools
- R, R Markdown; HTML / Chart.js; optional Shiny (`app.R`)

## Status
Complete

## Files
- `student_stress.rmd`, `uk_student_survey.rmd`, `student_survey_ver2.rmd`
- `index.html`, `style.css`, `dashboard_data.js` — static dashboard
- `app.R` — Shiny companion (needs local `student_stress.csv`)

## Final visuals
- Exploration dashboard: open `index.html` (or `shiny::runApp()`)
- **Peer recommendation prototype:** open `recommend.html` — wireframe-style
  “your recommendation” cards from similar-profile peers, with a professional-help referral

## Prototype files
- `recommend.html` / `recommend.css` / `recommend.js` / `recommend_data.js`

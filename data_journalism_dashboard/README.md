# Data Journalism Dashboard

## Summary
Interactive Shiny dashboard exploring media coverage themes around AI / GenAI —
volume over time, topic mix, growth vs a 2022 baseline, similarity between topic
sets, and correlations that help journalists see how the story evolved.

## Data & methodology
- Pre-aggregated chart layers (monthly volume, indexed growth, LOESS theme shares,
  topic counts, Jaccard similarity, rolling Pearson correlations, event response)
- Shiny app reads local CSVs named `01_*.csv` … `13_*.csv` (see `dashboard.R`)

## Data (not in git)
Keep the 13 aggregate CSVs locally beside `dashboard.R`. They are outputs of an
upstream media/NLP pipeline (not published in this repo).

**Describe:** monthly article-volume and theme-share aggregates for AI/GenAI
coverage, plus milestone and correlation tables used for journalism exploration.

## Limits & next steps
- Raw article corpus / NLP pipeline not shipped here
- Host a live Shiny instance for easier demos

## Tools
- R, Shiny, bslib, plotly, DT, dplyr, tidyr, scales, lubridate

## Status
Complete

## Files
- `dashboard.R` — Shiny app (expects local aggregate CSVs)

## Final visual
Shiny dashboard — theme volume, growth, and correlation views.

## Run locally
```r
# with 01–13 CSV aggregates present in this folder
shiny::runApp("dashboard.R")
```

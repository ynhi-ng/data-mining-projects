# Data Journalism Dashboard

## Summary
Interactive Shiny dashboard exploring media coverage themes around AI / GenAI —
volume over time, topic mix, growth vs a 2022 baseline, similarity between topic
sets, and correlations that help journalists see how the story evolved.

## Data & methodology
- Pre-aggregated CSV layers (monthly volume, indexed growth, LOESS theme shares,
  topic counts, Jaccard similarity, rolling Pearson correlations, event response)
- Built for exploration: snapshot charts, topic breakdowns, and correlation views
- Designed as a data-journalism / DVP-style exploratory dashboard

## Limits & next steps
- Relies on upstream CSVs; raw article corpus and NLP pipeline are not in this folder
- Hosting a live Shiny instance would make demos easier than local `runApp()` only

## Tools
- R, Shiny, bslib, plotly, DT, dplyr, tidyr, scales, lubridate

## Status
Complete

## Files
- `dashboard.R` — Shiny app
- `01_*.csv` … `13_*.csv` — chart-ready aggregates

## Run locally
```r
# from this directory
shiny::runApp("dashboard.R")
```

# Broadway Box Office Dashboard

## Summary
Interactive dashboard exploring weekly Broadway box office data (2005–2025) —
built for journalists to quickly see which shows are leading, how full houses
are running, and how the market has trended over time (including the 2020
COVID-19 collapse and recovery). Snapshot view, trend explorer, and leaderboard
are included.

## Data & methodology
- Clean weekly grosses: parse fields, fix closed weeks / missing financials /
  bad ticket prices, filter to 2005–present
- Shiny app: current-week snapshot, top-10 charts, leaderboard, trend explorer

## Limits & next steps
- Public weekly aggregates; no ticket-level microdata
- Local Shiny run; a hosted demo URL would improve portfolio sharing

## Tools
- R, Shiny, bslib, plotly, DT, dplyr, tidyr, scales

## Status
Complete

## Files
- `clean_data.R` — cleaning pipeline → `broadway_clean.csv`
- `broadway_clean.csv` — cleaned dataset used by the app
- `app.R` — Shiny dashboard

## Data Sources
- Broadway weekly box office grosses, 2005–2025 (public data)

## Run locally
```r
# from this directory
shiny::runApp()
```

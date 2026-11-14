# Broadway Box Office Dashboard

## Summary
Interactive dashboard exploring weekly Broadway box office data (2005–2025) —
built for journalists to quickly see which shows are leading, how full houses
are running, and how the market has trended over time (including the 2020
COVID-19 collapse and recovery). Snapshot view, trend explorer, and leaderboard
are included.

## Data & methodology
- Clean weekly grosses: parse fields, fix closed weeks / missing financials /
  bad ticket prices, filter to 2005–present (`clean_data.R` → local `broadway_clean.csv`)
- Shiny app: current-week snapshot, top-10 charts, leaderboard, trend explorer

## Data (not in git)
Place cleaned output locally as `broadway_clean.csv` after running `clean_data.R`.

**Source:** Broadway League weekly box office grosses (public weekly reports),
2005–present. Obtain the raw weekly table from public Broadway box-office
archives / scrapers you use, then run the cleaning script.

## Limits & next steps
- Public weekly aggregates; no ticket-level microdata
- Local Shiny run; a hosted demo URL would improve portfolio sharing

## Tools
- R, Shiny, bslib, plotly, DT, dplyr, tidyr, scales

## Status
Complete

## Files
- `clean_data.R` — cleaning pipeline (writes local `broadway_clean.csv`)
- `app.R` — Shiny dashboard

## Final visual
Shiny dashboard (`app.R`) — snapshot, leaderboard, and trend explorer.

## Run locally
```r
# after broadway_clean.csv exists in this folder
shiny::runApp()
```

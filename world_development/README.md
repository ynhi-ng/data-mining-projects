# World Development Indicators — EDA Report

## Summary
Exploratory data analysis of world development indicators, examining trends and
relationships across countries and regions, with a focus on FDI and related
development series from World Bank sources.

## Data & methodology
- World Bank / WDI-style indicator tables loaded locally for the R Markdown report
- dplyr transforms and ggplot2 visuals

## Data (not in git)
Download FDI / WDI extracts into this folder (e.g. `WorldBankGroup_FDI.csv`) before knitting.

**Source:** [World Bank Open Data](https://data.worldbank.org/) — World Development
Indicators and Foreign Direct Investment series (World Bank Group).

## Limits & next steps
- Exploratory only; not a causal country-comparison study
- Could add interactive maps or a shorter public HTML summary page

## Tools
- R, R Markdown, ggplot2, dplyr, tidyverse

## Status
Complete

## Files
- `world_development.rmd` — main analysis

## Final visual
R Markdown HTML report (knit `world_development.rmd`).

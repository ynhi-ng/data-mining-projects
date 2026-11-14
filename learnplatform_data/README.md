# LearnPlatform — Digital Learning Engagement EDA

## Summary
Exploratory analysis of K–12 digital learning engagement during 2020: how product
usage and access changed around the COVID outbreak, which platforms dominated, and
how engagement relates to district demographics (locale, race/ethnicity mix,
free/reduced lunch, per-pupil spend).

## Data & methodology
- Merge district engagement CSVs into one time series; join product and district info
- Clean engagement index / pct access; build Tableau-ready aggregates
- Compare weekday vs weekend engagement; pre- vs post-outbreak trends
- Product leaders (e.g. Google Docs / Classroom); locale and equity-gap views
- Correlations: engagement vs Black/Hispanic share and free/reduced lunch

## Limits & next steps
- Analysis complete in the notebook
- HTML findings report published as `index.html`
- Engagement files under `engagement_data/` are large; prefer the report for demos

## Tools
- Python, Jupyter, pandas, visualization (notebook); optional Tableau exports
- HTML — findings report

## Status
Complete

## Files
- `EDA_LearnPlatform_Final_Project.ipynb` — full EDA
- `districts_info.csv`, `products_info.csv`
- `engagement_data/` — per-district engagement CSVs
- `index.html`, `style.css` — findings report

## View report
Open `index.html` in a browser.

# Data Mining Projects

Code for the data science projects featured on my
[portfolio page](https://ynhi-ng.github.io/nhinguyen-ds-portfolio/).

## Projects

| Project | Description | Tools | Status |
|---|---|---|---|
| [World Development Indicators — EDA](world_development/) | Trends across countries and regions | R, R Markdown, ggplot2 | Complete |
| [Broadway Box Office](broadway_data/) | Shiny dashboard for weekly box office trends, 2005–present | R, shiny, plotly, dplyr | Complete |
| [E-Commerce Sales Report](ecommerce/) | Customer segmentation + product recommender; interactive HTML report | Python, scikit-learn, Chart.js | Complete |
| [Data Journalism Dashboard](data_journalism_dashboard/) | Media/GenAI theme exploration for journalists | R, Shiny, plotly | Complete |
| [Student Stress](student_stress/) | Survey EDA + interactive dashboard (`index.html` / Shiny) | R, Chart.js, Shiny | Complete |
| [NBA Players](nba_players/) | Player/season EDA + HTML findings report | Python, Jupyter, Chart.js | Complete |
| [LearnPlatform](learnplatform_data/) | 2020 digital learning engagement EDA + HTML report | Python, Jupyter | Complete |
| [ML Algorithm Projects](ml_algorithm_projects/) | Classification + exam-score prediction | R, caret, xgboost | Complete |
| [Melbourne Pedestrian Traffic](melbourne_peds_traffic/) | API ingest + quality checks for hourly foot traffic | Python, pandas | In progress |

Each project folder has its own README with data sources, methods, and findings.

**Data policy:** raw and cleaned tables (CSV/XLSX/parquet) are **not** tracked in
git. Download or regenerate them locally and follow the **Data (not in git)** /
citation notes in each project README. Small JS aggregates that power static HTML
reports (e.g. `ecommerce/data.js`) may stay in the repo.

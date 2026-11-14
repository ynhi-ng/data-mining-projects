# E-Commerce Sales Report

## Summary
Exploratory analysis and customer/product insights for a UK-based online gift
retailer (541,909 raw transactions, Dec 2010–Dec 2011). Cleans the raw
transaction log, then builds customer segmentation (K-means on RFM-style
features) and a product recommender (TF-IDF + cosine similarity on product
descriptions). Findings are published as a static, interactive report.

## Data & methodology
- Clean UCI Online Retail transaction log
- K-means on RFM-style customer features
- TF-IDF + cosine similarity recommender on product descriptions
- Export aggregates to `data.js` for the Chart.js report

## Data (not in git)
Keep `e-commerce_data.csv` locally (see folder `.gitignore`).

**Source:** Chen, D. (2015). Online Retail [Dataset]. UCI Machine Learning
Repository. https://doi.org/10.24432/C5BW33

## Limits & next steps
- Single retailer / one-year window; segments may not generalize
- Static report is portfolio-ready; live personalization not in scope

## Tools
- Python: pandas, numpy, scikit-learn, seaborn, matplotlib
- HTML, CSS, JavaScript, Chart.js

## Status
Complete

## Files
- `ecommerce_eda.ipynb` — cleaning, EDA, segmentation, recommender
- `data.js` — chart aggregates for the report (tracked)
- `index.html`, `style.css`, `script.js` — interactive report

## Final visual
Open `index.html` — “The Sales Report”.

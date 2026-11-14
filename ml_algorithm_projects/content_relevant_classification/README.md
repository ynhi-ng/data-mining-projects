# Content-Relevant Classification

## Summary
Supervised classification of forum posts as content-relevant or not. Independent
feature tables are joined to label tables on `Unique_ID`, cleaned for duplicates
and missing labels, then prepared across train / validation / test splits.

## Data & methodology
- Input: paired CSV files (`forum_ind_*` features, `forum_dep_*` labels) for train,
  validation, and test
- Join on `Unique_ID`; drop duplicate IDs and rows with missing labels
- Debug helpers check schema alignment and ID coverage before modeling

## Limits & next steps
- Notebook focuses on data prep and validation; document final model metrics in
  the portfolio write-up as you extend evaluation
- Consider a short model-card section (features used, class balance, metrics)

## Tools
- R (notebook), base data wrangling

## Status
Complete (analysis / pipeline work)

## Files
- `classification.ipynb` — load, debug, merge, and prepare splits
- `forum_ind_*.csv` / `forum_dep_*.csv` — feature and label tables

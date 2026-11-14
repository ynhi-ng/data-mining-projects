# Content-Relevant Classification

## Summary
Supervised classification of forum posts as content-relevant or not. Feature and
label tables are joined on `Unique_ID`, cleaned, and prepared across train /
validation / test splits.

## Data & methodology
- Join `forum_ind_*` (features) to `forum_dep_*` (labels) on `Unique_ID`
- Drop duplicate IDs and missing labels; validate schema before modeling

## Data (not in git)
Keep train / validation / test CSV pairs locally.

**Source:** Forum post feature/label splits from the classification task dataset
(independent feature tables + dependent label tables). Add the challenge or course
dataset link here when you publish it.

## Limits & next steps
- Document final model metrics in a short model card as you extend evaluation

## Tools
- R (notebook)

## Status
Complete

## Files
- `classification.ipynb` — load, debug, merge, prepare splits

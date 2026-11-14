# Kaggle Prediction Challenge — Student Exam Scores

## Summary
Regression challenge to predict student exam scores. Pipelines one-hot encode
categoricals, evaluate with RMSE, and compare LASSO vs XGBoost.

## Data & methodology
- Train / test tables with target `exam_score` on train
- 70/30 holdout; LASSO (`lambda.1se`) and XGBoost; RMSE metric

## Data (not in git)
Keep `train.csv` / `test.csv` (and any submission CSVs) locally under
`pred_test_score/`.

**Source:** Kaggle-style student exam score prediction challenge data. Add the
competition URL when available.

## Limits & next steps
- Task-specific features; limited external validation beyond holdout RMSE

## Tools
- R: dplyr, caret, glmnet, xgboost

## Status
Complete

## Files
- `pred_test_score/pred_student_score.ipynb` — cleaning, models, submissions
- `pred_test_score/pred_test_score.Rmd` — companion write-up

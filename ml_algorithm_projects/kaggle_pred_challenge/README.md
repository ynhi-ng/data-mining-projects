# Kaggle Prediction Challenge — Student Exam Scores

## Summary
Regression challenge to predict student exam scores. Pipelines one-hot encode
categorical features, evaluate with RMSE, and compare regularized linear models
(LASSO) against gradient boosting (XGBoost) for submission files.

## Data & methodology
- Train / test CSVs with target `exam_score` on the training set
- One-hot encoding for categoricals; 70/30 train–validation split
- LASSO (`glmnet`, lambda.1se) and XGBoost with parameter sweeps
- Primary metric: RMSE; export prediction CSVs for leaderboard submission

## Limits & next steps
- Challenge-specific feature set; limited external validation beyond holdout RMSE
- Could add feature-importance plots and residual diagnostics to an HTML report

## Tools
- R: dplyr, caret, glmnet, xgboost

## Status
Complete

## Files
- `pred_test_score/pred_student_score.ipynb` — cleaning, models, submissions
- `pred_test_score/RegressionPredictLabel*.csv` — prediction outputs

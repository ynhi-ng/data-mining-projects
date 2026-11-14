# Melbourne Pedestrian Traffic

## Summary
Pipeline to pull and quality-check hourly pedestrian counts from the City of
Melbourne Open Data API (Pedestrian Counting System). Ingestion paginates per
sensor under API row limits; parsing builds timestamps and documents missing hours.

## Data & methodology
- API ingest per `location_id` with pagination (page size 100) and retry/backoff
- Raw results saved locally (parquet) before cleaning
- Parsing notebook: timestamp construction, duplicates, nulls, missing-hour detection

## Limits & next steps
- **In progress** — ingestion + parsing done; fuller EDA / storytelling not finished
- Expand sensor set and date range; add trend / event analysis and a public summary

## Tools
- Python: requests, pandas, parquet I/O, Jupyter

## Status
In progress

## Files
- `data_ingestion.py` — API pull
- `data_parsing.ipynb` — quality checks
- `data/pedestrian_raw.parquet` — raw pull (may be gitignored later if large)

## Run locally
```bash
python data_ingestion.py
```

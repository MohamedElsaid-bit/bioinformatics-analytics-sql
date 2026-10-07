#!/usr/bin/env python3
"""Build the SQLite database from the committed schema and CSV extracts.

Run from the repo root:

    python3 scripts/build_db.py

Reads only files committed to this repo (sql/schema.sql and data/processed/*.csv),
so it is reproducible from a clone alone. No external packages required.
"""
import csv
import sqlite3
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SCHEMA_PATH = REPO_ROOT / "sql" / "schema.sql"
DATA_DIR = REPO_ROOT / "data" / "processed"
DB_PATH = DATA_DIR / "portfolio_analytics.sqlite"

# Table name -> (csv filename, column order matching the CSV header)
TABLES = [
    ("projects", "projects.csv"),
    ("pipeline_runs", "pipeline_runs.csv"),
    ("samples", "samples.csv"),
    ("run_samples", "run_samples.csv"),
    ("variant_calls", "variant_calls.csv"),
    ("de_results", "de_results.csv"),
    ("qc_metrics", "qc_metrics.csv"),
]


def load_csv_rows(path):
    with open(path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        return reader.fieldnames, [row for row in reader]


def main():
    if DB_PATH.exists():
        DB_PATH.unlink()

    conn = sqlite3.connect(DB_PATH)
    conn.executescript(SCHEMA_PATH.read_text())

    for table, filename in TABLES:
        fieldnames, rows = load_csv_rows(DATA_DIR / filename)
        placeholders = ", ".join("?" for _ in fieldnames)
        columns = ", ".join(fieldnames)
        values = [[row[col] if row[col] != "" else None for col in fieldnames] for row in rows]
        conn.executemany(
            f"INSERT INTO {table} ({columns}) VALUES ({placeholders})", values
        )
        print(f"Loaded {len(rows):5d} rows into {table}")

    conn.commit()
    conn.close()
    print(f"\nDatabase written to {DB_PATH.relative_to(REPO_ROOT)}")


if __name__ == "__main__":
    main()

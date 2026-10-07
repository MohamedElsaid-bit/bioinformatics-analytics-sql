#!/usr/bin/env python3
"""Reporting layer: run every query in sql/queries/, write each result set
to results/tables/<query_name>.csv, and print a short text summary.

Run from the repo root, after scripts/build_db.py:

    python3 scripts/run_report.py
"""
import csv
import sqlite3
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
DB_PATH = REPO_ROOT / "data" / "processed" / "portfolio_analytics.sqlite"
QUERIES_DIR = REPO_ROOT / "sql" / "queries"
TABLES_DIR = REPO_ROOT / "results" / "tables"


def run_query(conn, sql_path):
    cur = conn.cursor()
    cur.execute(sql_path.read_text())
    columns = [d[0] for d in cur.description]
    rows = cur.fetchall()
    return columns, rows


def write_csv(path, columns, rows):
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(columns)
        w.writerows(rows)


def main():
    if not DB_PATH.exists():
        raise SystemExit("Database not found. Run scripts/build_db.py first.")

    TABLES_DIR.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(DB_PATH)

    for sql_path in sorted(QUERIES_DIR.glob("*.sql")):
        columns, rows = run_query(conn, sql_path)
        out_path = TABLES_DIR / (sql_path.stem + ".csv")
        write_csv(out_path, columns, rows)

        print(f"\n== {sql_path.stem} ==")
        print(", ".join(columns))
        for row in rows:
            print(", ".join("" if v is None else str(v) for v in row))

    conn.close()
    print(f"\nWrote {len(list(QUERIES_DIR.glob('*.sql')))} result tables to {TABLES_DIR.relative_to(REPO_ROOT)}")


if __name__ == "__main__":
    main()

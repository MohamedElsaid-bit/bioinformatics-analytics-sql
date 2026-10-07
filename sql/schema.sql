-- Schema for a lightweight sample/run/results tracker across the portfolio's
-- bioinformatics pipelines. Modeled loosely on a LIMS: a project owns runs,
-- a run processes one or more samples and produces typed results (variant
-- calls, differential expression results) plus a generic QC metrics table
-- for the numbers that do not fit a fixed schema (Ti/Tv, PCA variance
-- explained, model accuracy, and so on).

PRAGMA foreign_keys = ON;

CREATE TABLE projects (
    project_id  INTEGER PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE,
    repo_url    TEXT,
    status      TEXT NOT NULL CHECK (status IN ('Planned', 'In Progress', 'Complete')),
    description TEXT
);

CREATE TABLE pipeline_runs (
    run_id           INTEGER PRIMARY KEY,
    project_id       INTEGER NOT NULL REFERENCES projects(project_id),
    pipeline_name    TEXT NOT NULL,
    pipeline_version TEXT,
    tools            TEXT,
    run_date         TEXT,
    runtime_seconds  REAL,
    runtime_notes    TEXT
);

CREATE TABLE samples (
    sample_id         INTEGER PRIMARY KEY,
    project_id        INTEGER NOT NULL REFERENCES projects(project_id),
    sample_name       TEXT NOT NULL,
    organism          TEXT,
    subject_or_donor  TEXT,
    condition         TEXT,
    source_accession  TEXT,
    notes             TEXT
);

-- Bridge table: a run processes one or more samples.
CREATE TABLE run_samples (
    run_id    INTEGER NOT NULL REFERENCES pipeline_runs(run_id),
    sample_id INTEGER NOT NULL REFERENCES samples(sample_id),
    PRIMARY KEY (run_id, sample_id)
);

CREATE TABLE variant_calls (
    variant_id   INTEGER PRIMARY KEY,
    run_id       INTEGER NOT NULL REFERENCES pipeline_runs(run_id),
    chrom        TEXT NOT NULL,
    pos          INTEGER NOT NULL,
    ref          TEXT NOT NULL,
    alt          TEXT NOT NULL,
    qual         REAL,
    filter       TEXT,
    variant_type TEXT CHECK (variant_type IN ('SNP', 'INDEL')),
    depth        INTEGER,
    allele_freq  REAL
);

CREATE TABLE de_results (
    result_id   INTEGER PRIMARY KEY,
    run_id      INTEGER NOT NULL REFERENCES pipeline_runs(run_id),
    gene_id     TEXT NOT NULL,
    gene_symbol TEXT,
    base_mean   REAL,
    log2fc      REAL,
    pvalue      REAL,
    padj        REAL,
    significant INTEGER CHECK (significant IN (0, 1)),
    direction   TEXT
);

-- Generic key/value fact table for the metrics that don't share a schema
-- across pipeline types (Ti/Tv, PCA variance explained, model accuracy...).
CREATE TABLE qc_metrics (
    metric_id    INTEGER PRIMARY KEY,
    run_id       INTEGER NOT NULL REFERENCES pipeline_runs(run_id),
    metric_name  TEXT NOT NULL,
    metric_value REAL,
    source_note  TEXT
);

CREATE INDEX idx_variant_calls_run ON variant_calls(run_id);
CREATE INDEX idx_variant_calls_filter ON variant_calls(filter);
CREATE INDEX idx_de_results_run ON de_results(run_id);
CREATE INDEX idx_de_results_significant ON de_results(significant);
CREATE INDEX idx_qc_metrics_run ON qc_metrics(run_id);
CREATE INDEX idx_samples_project ON samples(project_id);

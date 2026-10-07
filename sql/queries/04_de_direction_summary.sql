-- Summary of the DESeq2 call: how many genes were tested, how many were
-- significant, and the up/down split among the significant set. A CASE
-- expression inside aggregates stands in for a pivot, since SQLite has
-- no native PIVOT.
SELECT
    COUNT(*)                                                     AS genes_tested,
    SUM(significant)                                              AS significant_degs,
    SUM(CASE WHEN significant = 1 AND direction = 'Upregulated'
             THEN 1 ELSE 0 END)                                   AS degs_up,
    SUM(CASE WHEN significant = 1 AND direction = 'Downregulated'
             THEN 1 ELSE 0 END)                                   AS degs_down,
    ROUND(100.0 * SUM(significant) / COUNT(*), 2)                 AS pct_significant
FROM de_results;

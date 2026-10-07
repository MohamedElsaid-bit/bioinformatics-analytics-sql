-- Top 10 significant, upregulated genes by fold change (the kind of
-- lookup a biologist would actually run after the stats are done).
SELECT
    gene_symbol,
    ROUND(log2fc, 2) AS log2fc,
    padj,
    ROUND(base_mean, 1) AS base_mean
FROM de_results
WHERE significant = 1
  AND direction = 'Upregulated'
ORDER BY log2fc DESC
LIMIT 10;

-- How many raw HaplotypeCaller calls survived GATK hard filtering, split
-- by variant type. Demonstrates GROUP BY with multiple keys plus a
-- derived PASS rate.
SELECT
    variant_type,
    filter,
    COUNT(*) AS n_variants,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY variant_type), 1) AS pct_of_type
FROM variant_calls
GROUP BY variant_type, filter
ORDER BY variant_type, filter;

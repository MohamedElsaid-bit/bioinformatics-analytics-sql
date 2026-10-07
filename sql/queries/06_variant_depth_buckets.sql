-- Bucket PASS variants by read depth to show why depth-based filtering
-- was flagged as a future improvement in the variant-calling README:
-- most PASS calls sit at low-to-moderate depth.
SELECT
    CASE
        WHEN depth < 10            THEN 'under 10x'
        WHEN depth BETWEEN 10 AND 19 THEN '10x to 19x'
        WHEN depth BETWEEN 20 AND 34 THEN '20x to 34x'
        ELSE '35x or more'
    END AS depth_bucket,
    COUNT(*) AS n_variants
FROM variant_calls
WHERE filter = 'PASS'
GROUP BY depth_bucket
ORDER BY MIN(depth);

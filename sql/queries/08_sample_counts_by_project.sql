-- How many tracked samples feed each project, and the experimental
-- conditions represented (a basic join across samples and projects).
SELECT
    p.name AS project,
    COUNT(s.sample_id) AS n_samples,
    GROUP_CONCAT(DISTINCT s.condition) AS conditions_represented
FROM samples AS s
JOIN projects AS p ON p.project_id = s.project_id
GROUP BY p.project_id
ORDER BY p.project_id;

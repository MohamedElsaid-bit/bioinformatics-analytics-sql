-- Portfolio-wide status: one row per project, with its run count and
-- most recent run date pulled in via a LEFT JOIN (so Planned projects
-- with zero runs still show up).
SELECT
    p.name,
    p.status,
    COUNT(r.run_id)      AS run_count,
    MAX(r.run_date)      AS latest_run_date
FROM projects AS p
LEFT JOIN pipeline_runs AS r ON r.project_id = p.project_id
GROUP BY p.project_id
ORDER BY p.project_id;

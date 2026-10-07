-- Rank the runs that have a precise timed runtime (the window function
-- RANK() stands in here; with only one timed run today this is really
-- a placeholder for when more pipelines report a precise wall time).
SELECT
    p.name AS project,
    r.pipeline_name,
    r.runtime_seconds,
    r.runtime_notes,
    RANK() OVER (ORDER BY r.runtime_seconds ASC) AS speed_rank
FROM pipeline_runs AS r
JOIN projects AS p ON p.project_id = r.project_id
WHERE r.runtime_seconds IS NOT NULL
ORDER BY speed_rank;

-- Put each pipeline's headline QC metrics side by side as one row per run,
-- using conditional aggregation to pivot the long qc_metrics table wide.
-- This is the query that answers "how did each pipeline actually do,"
-- across three completely different kinds of pipeline, in one shot.
SELECT
    p.name AS project,
    r.pipeline_name,
    MAX(CASE WHEN m.metric_name = 'significant_degs' THEN m.metric_value END)        AS significant_degs,
    MAX(CASE WHEN m.metric_name = 'pass_variants' THEN m.metric_value END)           AS pass_variants,
    MAX(CASE WHEN m.metric_name = 'titv_ratio' THEN m.metric_value END)              AS titv_ratio,
    MAX(CASE WHEN m.metric_name = 'best_test_accuracy' THEN m.metric_value END)      AS best_test_accuracy,
    MAX(CASE WHEN m.metric_name = 'best_test_roc_auc' THEN m.metric_value END)       AS best_test_roc_auc
FROM pipeline_runs AS r
JOIN projects AS p ON p.project_id = r.project_id
LEFT JOIN qc_metrics AS m ON m.run_id = r.run_id
GROUP BY r.run_id
ORDER BY r.run_id;

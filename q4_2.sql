-- Task 4.2

-- Part A: total ratings and withdrawn ratings per movie, in one pass
SELECT
    movie_id,
    COUNT(*) AS total_ratings,
    COUNT(CASE WHEN rating_status = 'withdrawn' THEN 1 END) AS withdrawn_ratings
FROM ratings
GROUP BY movie_id
ORDER BY withdrawn_ratings DESC, total_ratings DESC;

-- Part B: regional subtotals and a platform grand total, no detail rows
SELECT
    CASE WHEN GROUPING(device_country) = 1 THEN 'All Regions'
        ELSE device_country END AS region,
    COUNT(*) AS total_ratings,
    COUNT(CASE WHEN rating_status = 'withdrawn' THEN 1 END) AS withdrawn_ratings,
    ROUND(100.0 * COUNT(CASE WHEN rating_status = 'withdrawn' THEN 1 END)
            / COUNT(*), 1) AS withdrawn_pct
FROM ratings
GROUP BY GROUPING SETS ((device_country), ())
ORDER BY GROUPING(device_country), region;

-- Part C: two-step pipeline, a baseline for high-volume movies
WITH movie_summary AS (
    SELECT
        movie_id,
        COUNT(*) AS total_ratings,
        COUNT(CASE WHEN rating_status = 'withdrawn' THEN 1 END) AS withdrawn_ratings,
        100.0 * COUNT(CASE WHEN rating_status = 'withdrawn' THEN 1 END)
            / COUNT(*) AS withdrawn_pct,
        AVG(score) AS avg_score
    FROM ratings
    Group BY movie_id
)
SELECT
    COUNT(*)                     AS high_volume_movies,
    ROUND(AVG(withdrawn_pct), 1) AS baseline_withdrawn_pct,
    ROUND(MIN(withdrawn_pct), 1) AS lowest_withdrawn_pct,
    ROUND(MAX(withdrawn_pct), 1) AS highest_withdrawn_pct,
    ROUND(AVG(avg_score), 2)     AS baseline_avg_score
FROM movie_summary
WHERE total_ratings >= 15;
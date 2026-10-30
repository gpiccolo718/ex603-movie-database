-- 4.1: Measure the platform
-- Calculate the platform's actual performance metrics

-- 1. Calculate count, total, average, minimum, and maximum scores.
SELECT
    COUNT(*) AS rating_count,
    SUM(score) AS total_score,
    ROUND(AVG(score), 2) AS avg_score,
    MIN(score) AS min_score,
    MAX(score) AS max_score,
    COUNT(DISTINCT user_id) AS distinct_users
FROM ratings;

-- 2. Event count and average metric per producer (movie), most active first
SELECT
    movie_id,
    COUNT(*) AS rating_count,
    ROUND(AVG(score), 2) AS avg_score
FROM ratings
GROUP BY movie_id
ORDER BY  rating_count DESC, movie_id;

-- 3. Producers with enough volume for their failure rate to mean something
--    Threshold: at least 15 ratings
SELECT
    movie_id,
    COUNT(*) AS rating_count,
    ROUND(AVG(score), 2) AS avg_score,
    COUNT(CASE WHEN rating_status = 'withdrawn' THEN 1 END) AS withdrawn_count,
    ROUND(100.0 * COUNT(CASE WHEN rating_status = 'withdrawn' THEN 1 END)
        / COUNT(*), 1) AS withdrawn_pct
FROM ratings
GROUP BY movie_id
HAVING COUNT(*) >= 15
ORDER BY withdrawn_pct DESC;

-- 4. Two dimensions at once: region (device_country) and rating status
SELECT
    device_country,
    rating_status,
    COUNT(*) AS rating_count,
    ROUND(AVG(score), 2) AS avg_score
FROM ratings
GROUP BY device_country, rating_status
ORDER BY device_country, rating_status;

-- Task 6.2: Compare each row to its neighbors

-- Part A (LAG/LEAD): For movie 11, is each rating's score higher or lower than the rating before it?
SELECT
    r.movie_id,
    r.rated_at,
    r.score,
    LAG(r.score) OVER (PARTITION BY r.movie_id ORDER BY r.rated_at, r.rating_id) AS prev_score,
    LEAD(r.score) OVER (PARTITION BY r.movie_id ORDER BY r.rated_at, r.rating_id) AS next_score,
    r.score - LAG(r.score) OVER (PARTITION BY r.movie_id ORDER BY r.rated_at, r.rating_id) AS score_delta
FROM ratings r
WHERE r.movie_id = 11
ORDER BY r.rated_at;

-- Part B (running total + moving average): How many ratings has the platform received so far,
-- what is the recent daily average, and how close did 2023 get to its target?
-- Target: 250 ratings in 2023 (about 21 per month)
WITH daily_ratings AS (
    SELECT
        r.rated_at::date AS rating_date,
        COUNT(*)         AS daily_count
    FROM ratings r
    GROUP BY r.rated_at::date
)
SELECT
    rating_date,
    daily_count,
    SUM(daily_count) OVER (
        ORDER BY rating_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_total,
    ROUND(AVG(daily_count) OVER (
        ORDER BY rating_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 2) AS moving_avg_7,
    ROUND(100.0 * SUM(daily_count) OVER (
        ORDER BY rating_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) / 250, 1) AS pct_of_target
FROM daily_ratings
ORDER BY rating_date;
-- Note: ROWS counts rows, not days. Ratings fall on only 155 of 365 days,
--       so a 7-row window often spans more than 7 calendar days.
-- ROWS vs RANGE: with ties in the ORDER BY value, ROWS treats each row separately,
--       while RANGE treats tied rows as one group and gives them the same result.

-- Part C (gap detection): Which movies went more than 90 days without a rating,
-- and when did the gap happen?
WITH rating_gaps AS (
    SELECT
        r.movie_id,
        r.rated_at,
        LAG(r.rated_at) OVER (PARTITION BY r.movie_id ORDER BY r.rated_at, r.rating_id) AS prev_rated_at,
        r.rated_at::date - LAG(r.rated_at) OVER (PARTITION BY r.movie_id ORDER BY r.rated_at, r.rating_id)::date AS gap_days
    FROM ratings r
)
SELECT
    movie_id,
    prev_rated_at AS gap_start,
    rated_at      AS gap_end,
    gap_days
FROM rating_gaps
WHERE gap_days > 90
ORDER BY gap_days DESC;
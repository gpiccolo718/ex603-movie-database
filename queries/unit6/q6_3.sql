-- Task 6.3: Build the reporting patterns

-- Part A (top N per category): What are the three highest-scored published ratings for each movie?
-- Ties at 3rd place: ROW_NUMBER with rated_at DESC as the tiebreaker, so each movie shows exactly 3 ratings
--   and the most recent of any tied ratings appear first.
-- (Many ratings tie at 5.0; RANK would return all of them, e.g. 6 published 5.0 ratings for movie 5.)
WITH ranked AS (
    SELECT
        r.movie_id,
        r.rating_id,
        r.score,
        r.rated_at,
        ROW_NUMBER() OVER (
            PARTITION BY r.movie_id
            ORDER BY r.score DESC, r.rated_at DESC
            ) AS score_rank,
        FIRST_VALUE(r.score) OVER (
            PARTITION BY r.movie_id
            ORDER BY r.score DESC
            ) AS movie_top_score
    FROM ratings r
    WHERE r.rating_status = 'published'
)
SELECT movie_id, rating_id, score, rated_at, score_rank, movie_top_score
FROM ranked
WHERE score_rank <= 3
ORDER BY movie_id, score_rank;

-- Part B (period over period): Is the withdrawal rate getting better or worse each month?
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', r.rated_at)::date AS month_start,
        COUNT(*) AS total_ratings,
        COUNT(*) FILTER (WHERE r.rating_status = 'withdrawn') AS withdrawn,
        ROUND(100.0 * COUNT(*) FILTER (WHERE r.rating_status = 'withdrawn') / COUNT(*), 1) AS withdrawal_rate
    FROM ratings r
    GROUP BY DATE_TRUNC('month', r.rated_at)
)
SELECT
    month_start,
    total_ratings,
    withdrawn,
    withdrawal_rate,
    LAG(withdrawal_rate) OVER (ORDER BY month_start) AS prev_month_rate,
    ROUND(100.0 * (withdrawal_rate - LAG(withdrawal_rate) OVER (ORDER BY month_start))
          / NULLIF(LAG(withdrawal_rate) OVER (ORDER BY month_start), 0), 1) AS pct_change
FROM monthly
ORDER BY month_start;

-- Part B check: Are any calendar months missing from the monthly series? (expect 0 rows)
WITH months AS (
    SELECT DISTINCT DATE_TRUNC('month', r.rated_at)::date AS month_start
    FROM ratings r
),
month_gaps AS (
    SELECT
        month_start,
        LAG(month_start) OVER (ORDER BY month_start) AS prev_month
    FROM months
)
SELECT month_start, prev_month
FROM month_gaps
WHERE prev_month <> month_start - INTERVAL '1 month'
ORDER BY month_start;

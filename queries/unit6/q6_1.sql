-- Task 6.1: Compute across a window without collapsing

-- Part 1a (window AVG): Is each rating unusual compared with its movie's average score?
SELECT
    r.rating_id,
    r.movie_id,
    r.score,
    ROUND(AVG(r.score) OVER (PARTITION BY r.movie_id), 2) AS movie_avg_score,
    ROUND(r.score - AVG(r.score) OVER (PARTITION BY r.movie_id), 2) AS diff_from_avg
FROM ratings r
ORDER BY r.movie_id, r.rating_id;

-- Part 1b (GROUP BY): What is each movie's average score? (one row per movie)
SELECT
    movie_id,
    ROUND(AVG(score), 2) AS movie_avg_score
FROM ratings
GROUP BY movie_id
ORDER BY movie_id;

-- Part 2 (ranking): How do the three ranking functions order movies by rating count, and how does each handle ties?
WITH movie_counts AS (
    SELECT movie_id, COUNT(*) AS rating_count
    FROM ratings
    GROUP BY movie_id
)
SELECT
    movie_id,
    rating_count,
    ROW_NUMBER() OVER (ORDER BY rating_count DESC, movie_id) AS row_num,
    RANK() OVER (ORDER BY rating_count DESC) AS rank_num,
    DENSE_RANK() OVER (ORDER BY rating_count DESC) AS dense_rank_num
FROM movie_counts
ORDER BY rating_count DESC, movie_id;

-- Part 3 (NTILE): If movies are split into four equal-sized bands by rating count, what happens to tied movies at a band boundary?
WITH movie_counts AS (
    SELECT movie_id, COUNT(*) AS rating_count
    FROM ratings
    GROUP BY movie_id
)
SELECT
    movie_id,
    rating_count,
    NTILE(4) OVER (ORDER BY rating_count DESC, movie_id) AS band
FROM movie_counts
ORDER BY rating_count DESC, movie_id;
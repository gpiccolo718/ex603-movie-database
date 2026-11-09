-- Task 5.3

-- Part A: Explore CROSS JOIN
-- Q1 (CROSS JOIN): What does every possible movie-genre combination look like?
SELECT
    mo.movie_id,
    mo.title,
    g.genre_name
FROM movies mo
    CROSS JOIN genres g
ORDER BY mo.movie_id, g.genre_name;

-- Q2 (row counts): Does the CROSS JOIN row count equal movies x genres? (expect 15 x 5 = 75)
SELECT
    (SELECT COUNT(*) FROM movies) AS movie_rows,
    (SELECT COUNT(*) FROM genres) AS genre_rows,
    (SELECT COUNT(*) FROM movies CROSS JOIN genres) AS cross_join_rows;

-- Part B: Examine a Query Execution Plan
-- How does PostgreSQL execute the three-table join from 5.1 Q1?
EXPLAIN ANALYZE
SELECT
    r.rated_at,
    u.user_name AS rated_by,
    mo.title AS movie_title
FROM ratings r
    INNER JOIN users u ON r.user_id = u.user_id
    INNER JOIN movies mo ON r.movie_id = mo.movie_id
ORDER BY r.rated_at DESC;
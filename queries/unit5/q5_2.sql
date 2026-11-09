-- Task 5.2

-- A: Compare INNER JOIN and LEFT JOIN
-- Q1: LEFT JOIN: Every movie with its ratings, including movies that have never been rated.
SELECT
    mo.movie_id,
    mo.title,
    r.rating_id
FROM movies mo
    LEFT JOIN ratings r ON mo.movie_id = r.movie_id
ORDER BY mo.movie_id;

-- Q2: INNER JOIN: Every movie that has at least one rating.
SELECT
    mo.movie_id,
    mo.title,
    r.rating_id
FROM movies mo
    INNER JOIN ratings r ON mo.movie_id = r.movie_id
ORDER BY mo.movie_id;

-- Q3: A count - How many distinct movies does each join return?
-- LEFT JOIN
SELECT COUNT(DISTINCT mo.movie_id) AS movies_left_join
FROM movies mo
    LEFT JOIN ratings r ON mo.movie_id = r.movie_id;

-- INNER JOIN
SELECT COUNT(DISTINCT mo.movie_id) AS movies_inner_join
FROM movies mo
    INNER JOIN ratings r ON mo.movie_id = r.movie_id;

-- B: Explore RIGHT JOIN and FULL OUTER JOIN
-- Q1: Every movie with its ratings, written as a RIGHT JOIN. Should match the LEFT JOIN from PART A.
SELECT
    mo.movie_id,
    mo.title,
    r.rating_id
FROM ratings r
    RIGHT JOIN movies mo ON r.movie_id = mo.movie_id
ORDER BY mo.movie_id;

-- Q3: FULL OUTER JOIN that includes matching and unmatched records from both tables.
SELECT
    mo.movie_id,
    r.movie_id AS rating_movie_id,
    mo.title,
    r.rating_id
FROM movies mo
    FULL OUTER JOIN ratings r ON mo.movie_id = r.movie_id
ORDER BY mo.movie_id;

-- C: Find Producers with No Events Using Two Approaches
-- Query using NOT EXISTS:
SELECT
    mo.movie_id,
    mo.title
FROM movies mo
WHERE NOT EXISTS (
    SELECT 1
    FROM ratings r
    WHERE mo.movie_id = r.movie_id
)
ORDER BY mo.movie_id;

-- Query using EXCEPT:
SELECT
    movie_id
FROM movies
EXCEPT
SELECT movie_id FROM ratings
ORDER BY movie_id;
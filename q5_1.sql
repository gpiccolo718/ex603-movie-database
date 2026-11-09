-- Task 5.1

-- Q1 (three-table join): Who rated each movie, which movie was it, and when?
SELECT
    r.rated_at,
    u.user_name AS rated_by,
    mo.title AS movie_title
FROM ratings r
    INNER JOIN users u ON r.user_id = u.user_id
    INNER JOIN movies mo ON r.movie_id = mo.movie_id
ORDER BY r.rated_at DESC;

-- Q2 (junction table): Which movies are tagged Comedy?
SELECT
    mo.movie_id,
    mo.title,
    g.genre_name
FROM movies mo
    INNER JOIN movie_genres mg ON mo.movie_id = mg.movie_id
    INNER JOIN genres g ON g.genre_id = mg.genre_id
WHERE g.genre_name = 'Comedy'
ORDER BY mo.movie_id DESC;

-- Q3 (self-join): Which movies share an origin country with the flagged movies?
SELECT
    m1.movie_id AS flagged_movie,
    m2.movie_id AS similar_movie,
    m1.origin_country
FROM movies m1
    INNER JOIN movies m2 ON m1.origin_country = m2.origin_country
                        AND m1.movie_id <> m2.movie_id
WHERE m1.movie_id IN (2, 9, 11)
ORDER BY m1.movie_id, m2.movie_id;



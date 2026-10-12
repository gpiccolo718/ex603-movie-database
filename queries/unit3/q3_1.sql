-- 3.1 Establish what the data contains

-- 1. Active, highly rated movies (first 10)
--    Requirement: SELECT, WHERE, ORDER BY, LIMIT.
SELECT movie_id, title, origin_country, release_year
FROM movies
WHERE is_available = TRUE
AND release_year > 2015
ORDER BY release_year DESC, title
LIMIT 10;

-- 2. All possible rating statuses.
--    Requirements: SELECT DISTINCT
SELECT DISTINCT rating_status
FROM ratings;

-- 3a. Filter ratings by a numeric range.
--     Requirements: BETWEEN
SELECT rating_id, user_id, movie_id, score
FROM ratings
WHERE score BETWEEN 3.0 and 5.0;

-- 3b. Filter ratings with an explicit list (IN)
--     Requirements: IN
SELECT rating_id, user_id, movie_id, ratings.rating_status
FROM ratings
WHERE rating_status IN ('flagged', 'withdrawn');

-- 4a. Movies whose titles match a text pattern.
--     Requirements: LIKE
SELECT movie_id, title
FROM movies
WHERE title LIKE 'Title_1%';

-- 4b. Ratings where the withdrawn reason is missing.
--     Requirements: NULL
SELECT rating_id, rating_status, withdrawn_reason
FROM ratings
WHERE withdrawn_reason IS NULL;

-- 4c. Replace missing reasons with a label.
--     Requirements: COALESCE
SELECT rating_id,
       rating_status,
       COALESCE(withdrawn_reason, 'No reason provided') AS reason
FROM ratings;

-- 5. Make the results easy to understand.
--    Requirements: CASE
SELECT rating_id, score,
       ROUND(score * weight, 2) AS weighted_score,
       CASE
           WHEN score >= 4.0 THEN 'Loved it'
           WHEN score >= 3.0 THEN 'Liked it'
           ELSE 'Disliked it'
       END AS rating_category
FROM ratings
WHERE rating_status = 'published';

-- 3.3 Three equivalent forms
-- Question: which users have had a rating withdrawn?

-- 1. Subquery with IN
SELECT user_id, user_name
FROM users
WHERE user_id IN (
    SELECT user_id
    FROM ratings
    WHERE rating_status = 'withdrawn'
)
ORDER BY user_id;

-- 2. Common Table Expression (WITH)
WITH withdrawn_users AS (
    SELECT user_id
    FROM ratings
    WHERE rating_status = 'withdrawn'
)
SELECT user_id, user_name
FROM users
WHERE user_id IN (SELECT user_id FROM withdrawn_users)
ORDER BY user_id;

-- 3. Correlated subquery with EXISTS
SELECT u.user_id, u.user_name
FROM users u
WHERE EXISTS (
    SELECT 1
    FROM ratings r
    WHERE r.user_id = u.user_id
      AND r.rating_status = 'withdrawn'
)
ORDER BY u.user_id;

-- 4. Proof the rows match: each EXCEPT must return 0 rows

-- Form 1 minus Form 3
SELECT user_id, user_name FROM users
WHERE user_id IN (SELECT user_id FROM ratings WHERE rating_status = 'withdrawn')
EXCEPT
SELECT u.user_id, u.user_name FROM users u
WHERE EXISTS (SELECT 1 FROM ratings r
              WHERE r.user_id = u.user_id AND r.rating_status = 'withdrawn');

-- Form 3 minus Form 1
SELECT u.user_id, u.user_name FROM users u
WHERE EXISTS (SELECT 1 FROM ratings r
              WHERE r.user_id = u.user_id AND r.rating_status = 'withdrawn')
EXCEPT
SELECT user_id, user_name FROM users
WHERE user_id IN (SELECT user_id FROM ratings WHERE rating_status = 'withdrawn');

-- Form 1 minus Form 2
SELECT user_id, user_name FROM users
WHERE user_id IN (SELECT user_id FROM ratings WHERE rating_status = 'withdrawn')
EXCEPT
SELECT user_id, user_name FROM users
WHERE user_id IN (SELECT user_id FROM ratings WHERE rating_status = 'withdrawn');
-- (Form 2's CTE inlines to this same query, so Form 2 minus Form 1 is identical)

-- 5. Where equivalence breaks: NOT IN with a NULL
-- Users who have NOT invited anyone. invited_by contains NULLs.
SELECT COUNT(*) AS not_in_result
FROM users
WHERE user_id NOT IN (SELECT invited_by FROM users);

SELECT COUNT(*) AS not_exists_result
FROM users u
WHERE NOT EXISTS (SELECT 1 FROM users i WHERE i.invited_by = u.user_id);
-- 3.2 The broken dashboard query

-- ===== Part A: The rows that vanished =====
-- Nullable column: ratings.withdrawn_reason (already contains NULLs, none inserted)

-- A1. Broken query: looks like "every rating except spam"
SELECT COUNT(*) AS not_spam
FROM ratings
WHERE withdrawn_reason != 'Spam detected';

-- A2. The opposite filter, and the table total
SELECT COUNT(*) AS spam
FROM ratings
WHERE withdrawn_reason = 'Spam detected';

SELECT COUNT(*) AS total_rows
FROM ratings;

-- A3. The rows A1 silently omitted
SELECT COUNT(*) AS silently_omitted
FROM ratings
WHERE withdrawn_reason IS NULL;

-- A4. Repair with an explicit IS NULL
SELECT COUNT(*) AS not_spam_fixed
FROM ratings
WHERE withdrawn_reason != 'Spam detected'
   OR withdrawn_reason IS NULL;


-- ===== Part B: The alias that did not exist yet =====

-- B1. Broken query: alias defined in SELECT, used in WHERE
SELECT rating_id, score * weight AS weighted_score
FROM ratings
WHERE weighted_score > 5;
-- Error message: [42703] ERROR: column "weighted_score" does not exist
--   Position: 73

-- B2. Rewrite 1: repeat the expression in WHERE
SELECT rating_id, score * weight AS weighted_score
FROM ratings
WHERE score * weight > 5;

-- B3. Rewrite 2: a CTE makes the alias a real column
WITH weighted AS (
    SELECT rating_id, score * weight AS weighted_score
    FROM ratings
)
SELECT rating_id, weighted_score
FROM weighted
WHERE weighted_score > 5;

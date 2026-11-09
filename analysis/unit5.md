# Unit 5 Write-up

## Task 5.1

### Where the three-table join would be used

The three-table join from Question 1 could power a **rating activity log** for the platform's moderation team. Each row shows who submitted a rating, which movie it was for, and when, newest first. A moderator investigating a problem movie, such as movie 2, where three of its four withdrawn ratings were removed as spam, could use this view to see which accounts rated it and whether those ratings arrived in a suspicious burst. The ratings table alone only stores `user_id` and `movie_id` numbers. Joining in `users` and `movies` turns those IDs into names and titles a person can actually read. The join returned all 200 ratings, which confirms that every rating has a matching user and movie and that nothing was dropped.

### Why the junction table matters

A movie can belong to several genres, and each genre applies to many movies. That many-to-many relationship cannot be stored in either table on its own. The `movie_genres` junction table holds one row per movie–genre pair, which is what makes Question 2 possible: I started from `movies`, went through `movie_genres`, and reached `genres` to filter on Comedy. That returned five movies (2, 3, 5, 10, and 11), including two of the three movies I flagged in Assignment 4.

I chose Comedy because it is the only genre shared by movie 11, which has the highest withdrawal rate, and movie 2, which has the most spam withdrawals. Movie 9, the third flagged movie, is tagged only as Drama, so Comedy does not explain all three.

Without the junction table, genres would have to be stored inside the `movies` table, either as a list in one column (for example `'Drama, Comedy, Thriller'`) or as a fixed set of columns like `genre_1`, `genre_2`, `genre_3`. Both make this analysis harder. A list in one column cannot be joined or indexed, so finding every Comedy movie would require text matching that could also catch a genre like "Dark Comedy" by mistake. A fixed set of columns forces every query to check each column separately and breaks as soon as a movie needs one more genre than there are columns. The junction table keeps each fact in one row, so a plain join and a `WHERE` filter answer the question reliably.

### What the self-join shows

The self-join in Question 3 paired each flagged movie with every other movie from the same origin country: movie 11 with movies 3, 5, and 12 (Brazil), movie 2 with movie 6 (Vietnam), and movie 9 with movie 13 (US). I used `<>` rather than `<` because the `WHERE` clause already limits the left side to the flagged movies, so the only pairing to rule out is a movie with itself. Since no two flagged movies share a country, no pair can appear twice.

Comparing each flagged movie with its peers suggests that origin country does not explain the high withdrawal rates. In every country, the flagged movie has a higher withdrawal rate than the other movies from that country:

| Country | Flagged movie | Withdrawal rate | Same-country movies |
|---|---|---|---|
| Brazil | 11 | 31.2% (5 of 16) | 3: 23.1%, 5: 16.7%, 12: 11.8% |
| Vietnam | 2 | 25.0% (4 of 16) | 6: 19.0% |
| US | 9 | 28.6% (4 of 14) | 13: 9.1% |

The flagged movies' activity levels also look like their peers' (14 to 16 ratings each, compared with 11 to 21 for the others), so low volume alone does not explain their rates either. Whatever is driving the withdrawals seems to be specific to each movie rather than shared by the region it comes from. For movie 2 in particular, the spam pattern points toward targeted fake ratings, not a regional or quality issue.

## Task 5.2

### Part A: INNER JOIN vs. LEFT JOIN

The LEFT JOIN from `movies` to `ratings` returned 202 rows covering **15 distinct movies**. The INNER JOIN returned 200 rows covering **13 distinct movies**. The inner join excluded **2 movies: movie 14 (Title_14) and movie 15 (Title_15)**. I counted with `COUNT(DISTINCT mo.movie_id)` so that a movie with many ratings was only counted once. I used the `movies` side of the ID because it stays filled in even when there is no matching rating.

These two movies are missing because they have no rows in `ratings`. An INNER JOIN only keeps a movie when at least one rating matches it, so a movie that has never been rated disappears from the result without any warning. In the LEFT JOIN, the same two movies appear once each with `NULL` in `rating_id`.

### Part B: RIGHT JOIN and FULL OUTER JOIN

I rewrote the LEFT JOIN as a RIGHT JOIN by swapping the table order (`FROM ratings r RIGHT JOIN movies mo`), so `movies` is still the table whose rows are all kept. To confirm the two queries are equivalent, I compared their results: both returned 202 rows, and the rows matched, including movies 14 and 15 with `NULL` ratings.

The FULL OUTER JOIN also returned 202 rows, identical to the LEFT JOIN. A full outer join keeps unmatched rows from **both** tables, so it can reveal two kinds of gaps at once: movies with no ratings, and ratings that point to a movie that does not exist. A LEFT JOIN from `movies` can only show the first kind, and a LEFT JOIN from `ratings` can only show the second. I included both `mo.movie_id` and `r.movie_id` in the output so an orphan rating would be visible as a row with no movie. None appeared. That is expected, because `ratings.movie_id` is `NOT NULL` and has a foreign key to `movies`, so the database itself prevents orphan ratings. The full outer join therefore confirms the data is clean on that side. It would matter much more for data without foreign keys, or when comparing two separate sources such as a production table and an imported copy.

### Part C: NOT EXISTS vs. EXCEPT

Both approaches returned the same two movies, 14 and 15. NOT EXISTS checks each movie for a matching rating and can return any column from `movies`, such as the title. EXCEPT subtracts the list of rated movie IDs from the list of all movie IDs, so it only returns the compared column and automatically removes duplicates.

### What the results mean

**Which producers were excluded.** Movies **14** and **15**.

**What it means for a producer to have no events.** On this platform, it means no user has ever rated the movie. The data shows that both movies are in the catalog and both are marked available (`is_available = TRUE`), so they are not hidden from users. Both were added in early 2022 (February 21 and April 11), well before the ratings in the data, which all fall in 2023. They have had the chance to be rated and have not been.

Possible explanations include:

- **They are hard to find.** Neither movie has any genre tag in `movie_genres`, so they would not appear when users browse by genre. This is the strongest lead in the data, but it is not proof: movie 13 also has no genre tags and still received 11 ratings.
- **They are older titles.** They were released in 2013 and 2008, so they may not be promoted to users. Age alone does not explain it, though: movies 6 and 7 were also released in 2008 and received 21 and 18 ratings.
- **Users watch them but do not rate them.** The ratings table only records ratings, not viewing, so a movie can be watched without leaving any trace here.
- **A data or listing problem**, such as the movie not displaying correctly in the app.

**What the data shows vs. what needs further investigation.** The data shows *that* movies 14 and 15 have zero ratings, are listed as available, have no genre tags, and were added well before the rating period. It does not show *why* they have no ratings. Confirming a cause would need data this database does not have, such as viewing logs, search and browse traffic, or how the movies are shown in the app.

**How an inner-join-only report gives an incomplete picture.** Any report built on an INNER JOIN between movies and ratings, such as average score per movie or withdrawal rate per movie, would show 13 movies and never mention the other 2. Leadership would see a catalog that looks fully active and could reasonably assume every movie is getting engagement. The problem is not a wrong number. It is a missing row that nobody notices. It also understates the catalog: 2 of 15 movies, about 13%, have no engagement at all.

**Why leadership would want to identify never-active producers.** Every movie in the catalog has a cost, such as licensing, storage, and space in listings, whether or not anyone engages with it. A movie with zero ratings is either an untapped opportunity that users have not found, or content that is not worth keeping. Neither can be addressed until leadership knows these movies exist. They are also a different problem from the movies with high withdrawal rates, which do get attention but attract spam or bad ratings.

**What action leadership could take.** First, fix the most likely cause shown in the data: add genre tags to movies 14 and 15 so they appear in genre browsing, and consider featuring them briefly. Then check again after a set period. If they start receiving ratings, the problem was discoverability. If they still receive none, review whether to keep them in the catalog. Going forward, any engagement report should be built with a LEFT JOIN from `movies`, so movies with no activity always appear with a count of zero rather than disappearing.

## Task 5.3

### When a Cartesian product is useful

My CROSS JOIN paired all 15 movies with all 5 genres. The counts confirm the multiplication: 15 × 5 = 75 rows. On this platform, that grid is useful as a **tagging checklist**. It lists every movie–genre combination that *could* exist, so left-joining `movie_genres` onto it would show which combinations are actually tagged and which are not, including movies such as 13, 14, and 15 that currently have no genre at all. The same pattern could build a report of ratings per genre per country that shows zeros instead of leaving empty combinations out.

A Cartesian product usually signals an error when it was not intended. If the `ON` condition were left off a join between `ratings` (200 rows) and `users` (30 rows), the query would quietly return 6,000 rows, pairing every rating with every user. On a real platform with millions of ratings, that mistake could produce billions of rows and run for hours. A result that is much larger than either input table is the warning sign.

### Reading the execution plan

I ran `EXPLAIN ANALYZE` on the three-table join from Task 5.1, Question 1. The full plan:

```
Sort  (cost=35.98..36.48 rows=200 width=524) (actual time=0.214..0.222 rows=200.00 loops=1)
  Sort Key: r.rated_at DESC
  Sort Method: quicksort  Memory: 34kB
  Buffers: shared hit=30
  ->  Nested Loop  (cost=12.40..28.34 rows=200 width=524) (actual time=0.059..0.177 rows=200.00 loops=1)
        Buffers: shared hit=30
        ->  Hash Join  (cost=12.25..17.80 rows=200 width=270) (actual time=0.041..0.090 rows=200.00 loops=1)
              Hash Cond: (r.user_id = u.user_id)
              Buffers: shared hit=4
              ->  Seq Scan on ratings r  (cost=0.00..5.00 rows=200 width=16) (actual time=0.016..0.027 rows=200.00 loops=1)
                    Buffers: shared hit=3
              ->  Hash  (cost=11.00..11.00 rows=100 width=262) (actual time=0.016..0.016 rows=30.00 loops=1)
                    Buckets: 1024  Batches: 1  Memory Usage: 10kB
                    Buffers: shared hit=1
                    ->  Seq Scan on users u  (cost=0.00..11.00 rows=100 width=262) (actual time=0.006..0.009 rows=30.00 loops=1)
                          Buffers: shared hit=1
        ->  Memoize  (cost=0.15..0.41 rows=1 width=262) (actual time=0.000..0.000 rows=1.00 loops=200)
              Cache Key: r.movie_id
              Cache Mode: logical
              Hits: 187  Misses: 13  Evictions: 0  Overflows: 0  Memory Usage: 2kB
              Buffers: shared hit=26
              ->  Index Scan using movies_pkey on movies mo  (cost=0.14..0.40 rows=1 width=262) (actual time=0.002..0.002 rows=1.00 loops=13)
                    Index Cond: (movie_id = r.movie_id)
                    Index Searches: 13
                    Buffers: shared hit=26
Planning Time: 0.192 ms
Execution Time: 0.265 ms
```

**Which join algorithms PostgreSQL chose.** It used two different algorithms for the two joins:

- A **Hash Join** to connect `ratings` to `users`. PostgreSQL read all 30 users, built an in-memory hash table on `user_id` (10 kB), then scanned all 200 ratings and looked up each rating's user in that table.
- A **Nested Loop** to connect that result to `movies`. For each of the 200 rows, it looked up the movie through the `movies_pkey` index. A **Memoize** step cached each lookup, so only 13 real index searches were needed (one per distinct movie that has ratings). The other 187 lookups came from the cache.

The final `Sort` ordered the 200 rows by `rated_at` in memory using quicksort. The whole query ran in 0.265 ms.

**What in the plan explains these choices.**

- *Join conditions and table size:* both joins use equality (`Hash Cond: r.user_id = u.user_id` and `Index Cond: movie_id = r.movie_id`), which makes a hash join possible. `users` is small (30 rows, 10 kB of memory), so it is cheap to hash.
- *Available indexes:* `ratings` has no index on `user_id`, so there is no faster way to reach users than hashing them. `movies` does have an index, its primary key `movies_pkey`, so a nested loop with one index lookup per row is cheap. That matches the lesson's rule that a nested loop wins when the inner side is indexed.
- *Repeated values:* the `Memoize` line (`Hits: 187 Misses: 13`) shows that the 200 ratings only reference 13 different movies, so caching made the nested loop even cheaper.
- *Row estimates:* the scan on `users` estimated 100 rows, but the actual count was 30. That gap suggests the planner is working from default or outdated statistics. Running `ANALYZE` would give it accurate counts. Here the gap did not change the outcome, but on large tables a bad estimate can lead the planner to a poor algorithm.

**Why understanding the join algorithm is useful.** The algorithm tells you where a query will slow down and what will fix it. A hash join that stops fitting in memory, a nested loop running millions of lookups, or a sequential scan of a huge table each has a different remedy: more memory, an index, a filter, or fresh statistics. Reading the plan turns "the query is slow" into a specific cause that can be fixed, instead of guessing.

**What might become less efficient as the platform grows.** The **sequential scan of `ratings`** is the step most likely to become expensive, because the query reads every rating every time it runs, and ratings is the table that grows fastest. The **sort** grows with it and would move from memory to disk once it no longer fits. As the number of users grows, the **hash table** built from `users` could also outgrow memory and spill to disk. As more movies receive ratings, Memoize's cache hit rate would drop, and the nested loop would make many more real index lookups.

**What changes might make another algorithm more appropriate.** If `ratings` and `users` both grew to millions of rows and both were indexed on `user_id`, a **merge join** could become cheaper than hashing, because both sides could be read in sorted order. If the query were filtered to a small slice of ratings, for example one day's ratings with an index on `rated_at`, PostgreSQL might switch the users join to a **nested loop**, since a handful of indexed lookups would cost less than hashing the whole users table. Adding an index on `ratings.user_id` would also give the planner more options.

## Reflection

PostgreSQL's choice of join algorithm depends on the size of each table, which indexes exist, and how many rows are expected to match, so a change to any of these could produce a different plan. In my plan, `users` was joined with a hash join because it is small and `ratings.user_id` has no index, while `movies` was joined with a nested loop because each lookup could use its primary key index.

If `users` grew to millions of rows, its hash table might no longer fit in memory and would spill to disk, which slows a hash join considerably. If both `ratings` and `users` were then indexed on `user_id`, the planner could read both in sorted order and choose a merge join instead. Going the other way, if the query only needed a small number of matching rows, such as one user's ratings or one day's activity with an index on `rated_at`, a nested loop with index lookups would likely become cheapest, because it would touch only the rows it needs.

The number of matching records matters too. My plan was cheap partly because the 200 ratings referenced only 13 movies, so Memoize could reuse earlier lookups. With thousands of distinct movies, that cache would help much less. Finally, accurate statistics matter: the planner estimated 100 users when there were 30. On large tables, a wrong estimate like that could lead it to pick a slower algorithm, which is why running `ANALYZE` after large data changes is worthwhile.

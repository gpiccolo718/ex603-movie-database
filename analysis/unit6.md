# Unit 6 Write-up

## Task 6.1: Compute across a window without collapsing

### A question that needs each row next to its group's average

**Question:** *Which individual ratings are far below their own movie's normal score, and might be spam?*

To answer it, every rating has to sit next to its movie's average on the same row, so the gap between the two can be measured. The window query in Part 1a does this: `AVG(score) OVER (PARTITION BY movie_id)` attaches each movie's average to all of its ratings and keeps all **200 rows**. The largest gaps are the withdrawn ratings scored 0.5. On movie 5, for example, three withdrawn 0.5 ratings sit about 3 points below the movie's average.

The GROUP BY version in Part 1b answers a different question. It returns **13 rows**, one per rated movie, with the same averages. It loses every individual rating in the process, so it can say that movie 11 averages 2.09 but not *which* of movie 11's ratings are pulling that average down. Spotting an unusual rating needs both the rating and its group's average at once, and only the window function keeps both.

### Ranking movies, and why the tie rule matters

Part 2 ranked the 13 rated movies by number of ratings using all three functions side by side. The data has three ties: movies 5 and 7 (18 ratings each), movies 2 and 11 (16 each), and movies 1 and 13 (11 each). On the tie between movies 2 and 11, `ROW_NUMBER` placed them 7th and 8th, `RANK` placed both 7th and skipped to 9th for the next movie, and `DENSE_RANK` placed both 6th with no gap.

**Platform feature:** a public **"Most-Rated Movies" leaderboard** on the home page.

It should use **`RANK`**. Movies with the same number of ratings performed identically, so the leaderboard should not suggest one beat the other. `ROW_NUMBER` would show movie 2 above movie 11 only because of the `movie_id` tiebreaker I added, which is an arbitrary database detail, not a difference in performance. `DENSE_RANK` treats ties fairly, but by skipping no positions it implies there are fewer movies ahead than there really are. For example, it shows movie 9 as 7th when eight movies have more ratings. `RANK` is the honest choice: tied movies share a position, and the gap after a tie shows that two places were taken.

### NTILE and tied movies at a boundary

Part 3 split the 13 movies into four bands with `NTILE(4)`, which produced bands of 4, 3, 3, and 3 movies. Because NTILE fills bands by row count rather than by value, tied movies can be separated. Movies 5 and 7 both have 18 ratings, but movie 5 landed in band 1 and movie 7 in band 2. Movies 2 and 11 both have 16 ratings, but landed in bands 2 and 3. The only thing deciding which tied movie went higher was the `movie_id` tiebreaker. Any feature built on these bands, such as promoting "band 1" movies, would treat two equally performing movies differently.

## Task 6.2: Compare each row to its neighbors

### What a large delta means

Part A followed movie 11's ratings in time order with `LAG` and `LEAD` and computed each rating's change from the one before. The largest drop was **−3.2** on March 4, 2023, when a 3.7 rating was followed by a 0.5. Several more 0.5 ratings followed. On this platform, a sudden fall to 0.5 is the score withdrawn ratings carry, so a large negative delta is a signal that a movie may be receiving spam or fake ratings, rather than a sign that the movie got worse.

**What to do about it:** a large drop should trigger a moderation check of the ratings involved before anyone acts on the movie's average. If the low ratings come from a cluster of accounts in a short time, they should be reviewed as possible spam. If the low ratings are genuine, the movie's average is accurate and needs no correction.

### Why a running total answers a question a plain SUM cannot

A plain `SUM` gives one number: the platform received **200 ratings** in 2023. A running total shows **how the platform got there**, day by day. My target was **250 ratings for the year**, and the running total in Part B ends at 200, or **80% of the target**. It also shows the pace along the way: by the end of June, the running total was 101, about 40% of the target with half the year gone. A plain SUM would only reveal the 20% shortfall at the end of the year. The running total shows the platform was already falling behind at mid-year, when there was still time to act.

### Why I picked a 7-row moving average

I used a 7-row window (`ROWS BETWEEN 6 PRECEDING AND CURRENT ROW`) because seven is the conventional window for smoothing daily activity into a weekly pattern. It smooths out single busy or quiet days without hiding changes that last a few weeks.

The window counts rows, not days, and that matters here. Ratings fall on only **155 of the 365 days** in 2023, so the daily series skips the days with no ratings, and a 7-row window often covers two weeks or more of calendar time. A smaller window, such as 3 rows, would jump around with each individual day. A larger one, such as 30 rows, would cover several months and hide recent changes. At the end of the year, the 7-row average was about 1.1 to 1.4 ratings per active day. That is a low and steady pace, consistent with the platform finishing below its target.

**ROWS vs. RANGE:** when two rows share the same `ORDER BY` value, `ROWS` treats them as separate rows and includes them one at a time, while `RANGE` treats all tied rows as one group and gives every one of them the same result. In Part B each date appears only once, so the two would match here. With ties, a RANGE running total would jump by the whole group at once.

### What a gap means on this platform

Part C used `LAG` to measure the time between each movie's consecutive ratings and kept only the gaps longer than 90 days. Three movies went more than a full quarter without a rating: **movie 9 (113 days, January 5 to April 28)**, **movie 12 (107 days, March 2 to June 17)**, and **movie 5 (93 days, February 1 to May 5)**.

These gaps are most likely a **real quiet stretch in user activity**, not a data quality problem:

- **The gaps happened at different times for different movies.** If the data pipeline had lost records, every movie would go quiet over the same dates.
- **The platform kept receiving ratings throughout.** The missing-month check in Task 6.3 returned 0 rows: every month of 2023 has ratings, so data was being recorded during each of these gaps.
- **Each movie came back.** All three received ratings again afterward and kept receiving them through late 2023.
- **Gaps are normal at this scale.** With only 200 ratings across 13 movies in a year, each movie averages about one rating every three weeks, so long quiet stretches are expected.

What the data cannot show is *why* users stopped rating these movies for a while: whether they stopped watching, or watched without rating. Answering that would need viewing data, which this database does not store.

## Task 6.3: Build the reporting patterns

### The feature top-N would power

The top-3 query in Part A powers a **"Top Reviews" section on each movie's page**, showing the three highest-scored published ratings for that movie. I only included ratings with `rating_status = 'published'`, so flagged or withdrawn ratings can never appear in a public highlight.

**Why three:** one review is a single opinion and easy to game, since a single fake 5.0 would become the whole section. Ten reviews is too many for a small panel, and on a platform where most movies have 11 to 21 ratings, a top ten would include much of every movie's history, including middling ones. Three gives visitors a range of strong opinions while staying selective.

**Ties at third place:** many ratings tie at 5.0. Movie 5 alone has six published 5.0 ratings. I used `ROW_NUMBER` with `rated_at DESC` as the tiebreaker, so each movie shows exactly three ratings and the most recent of any tied ratings come first. `RANK` would have shown all six of movie 5's 5.0 ratings, which breaks a fixed three-slot layout.

### What a large month-over-month change means

Part B compared each month's withdrawal rate with the previous month's using `LAG`, with `NULLIF` preventing division by zero. That safeguard mattered: April had **0 withdrawals**, so May's percentage change would have divided by zero. It shows as NULL instead.

The month-to-month changes are large. June's withdrawal rate rose **111.9%** from May's (11.8% to 25.0%), and July's fell **52.8%** (25.0% to 11.8%). On this platform, a jump like June's could mean a wave of spam ratings, a new policy causing more removals, or a few problem accounts. **What to do:** look at *which* ratings were withdrawn that month and why, and check whether they cluster around particular movies or accounts.

The first thing to check, though, is **sample size**. Each month has only 11 to 21 ratings, so one or two withdrawals move the rate by 5 to 10 percentage points. June's 111.9% jump came from going from 2 withdrawals to 5. Month-over-month percentages exaggerate swings at this volume, so the team should judge the trend over longer periods, such as quarters, before reacting to any single month.

The missing-month check returned **0 rows**, confirming that all 12 months are present, so each `LAG` compares a month with the one immediately before it.

## Reflection

On this platform, a common reporting question is: *"Is this rating unusual for the movie it was given to?"* A moderator reviewing possible spam needs each rating next to its movie's typical score, to judge whether the gap is worth investigating.

A window function answers this in one step. `AVG(score) OVER (PARTITION BY movie_id)` computes each movie's average and attaches it to every one of that movie's ratings, keeping all 200 rows. The difference between each score and its movie's average can then be calculated on the same row, which is how my Task 6.1 query showed withdrawn 0.5 ratings sitting 2 to 3 points below their movies' averages.

GROUP BY alone cannot do this, because it collapses the ratings into one row per movie. It produces the averages but throws away the individual ratings that need comparing. Getting both back means writing a second query: computing the averages in a subquery or CTE, then joining that result back to the ratings table on `movie_id`. That works, but it is longer and adds a join that can go wrong.

The same pattern appeared across the unit. Running totals, the previous and next rating with `LAG` and `LEAD`, and rankings all depend on seeing a row and its neighbors together. GROUP BY answers questions about groups; window functions answer questions about individual rows *in the context of* their group, which is what most moderation and reporting work actually needs.

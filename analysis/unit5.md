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

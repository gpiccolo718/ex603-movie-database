# Task 2.2 — Constraints and Design Reasoning

## Foreign Key Constraints

| Foreign Key | ON DELETE | Reason |
|---|---|---|
| `ratings.account_id` → `users.account_id` | CASCADE | A deleted user's ratings should not remain, so that aggregate scores only reflect currently active users. |
| `ratings.title_id` → `movies.title_id` | CASCADE | A hard-deleted movie is treated as an erroneous entry, and any ratings tied to it are equally invalid. |
| `movie_genre.title_id` → `movies.title_id` | CASCADE | A genre tag has no independent meaning once the movie it describes no longer exists. |
| `movie_genre.genre_id` → `genre.genre_id` | RESTRICT | Deleting a genre is a rare, platform-wide action, and should require explicit cleanup rather than silently untagging every associated movie. |

### Expanding on the ON DELETE choices

**`ratings.account_id` → `users.account_id` (CASCADE).** When a user account is deleted from the platform, every rating that user submitted is deleted along with it. This directly affects the accuracy of a movie's aggregate score: since `average_score` is computed from `Ratings.Score`, allowing ratings from deleted accounts to remain would let a movie's displayed score be influenced by users who are no longer part of the platform. Under the alternative (RESTRICT), an account could never be deleted while it had any ratings on file. For an active user with dozens of ratings, that would make account deletion functionally impossible without a separate bulk-cleanup step first.

**`ratings.title_id` → `movies.title_id` (CASCADE).** Movies has an `is_active` flag specifically for removing a title from listings without deleting it, so the common case of "delisting a movie" never triggers this ON DELETE behavior at all — the row and its ratings simply remain, untouched, with `is_active` set to false. A hard `DELETE` on Movies is reserved for the rarer case of correcting a duplicate or erroneous entry. In that case, any ratings pointing at the erroneous row are equally invalid and should be removed with it. Under the alternative (RESTRICT), correcting even a simple duplicate movie entry would require manually deleting every rating tied to it first, adding friction to a cleanup operation that should be straightforward.

**`movie_genre.title_id` → `movies.title_id` (CASCADE).** A row in `movie_genre` records a genre tag *about* a specific movie. It carries no meaning on its own. When a movie is deleted, its genre tags are removed automatically, since a genre association for a movie that no longer exists is not just orphaned data, it's meaningless data. The alternative (RESTRICT) would block a movie's deletion entirely while any genre tags existed on it, which would apply to nearly every movie in the system and add no real protection against a mistaken deletion.

**`movie_genre.genre_id` → `genre.genre_id` (RESTRICT).** This is the one foreign key that behaves differently from the rest, and deliberately so. Deleting a genre (say, removing "horror" from the platform entirely) is a rare, structural, platform-wide change. Unlike deleting one movie, it would silently untag every movie associated with that genre, potentially hundreds of rows, in a single operation. Someone or something (an administrator, or a migration script) is affected by this choice: they cannot delete a genre while movies are still tagged with it, and must explicitly reassign or remove those tags first. Under the alternative (CASCADE), a single accidental genre deletion could quietly strip genre information from a large portion of the catalog with no warning and no recovery path.

## CHECK Constraints

**`chk_movies_duration_min` — `CHECK (duration_minutes > 0)`.** This prevents a movie from being stored with a zero or negative runtime. Without this constraint, a data entry error (a typo, a missing value defaulting to 0, or a sign error from an import script) could silently produce a movie with an impossible duration, which would corrupt any feature relying on runtime (sorting by length, estimating total watch time, or flagging suspiciously short or long entries).

**`chk_ratings_score` — `CHECK (score IN (0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0))`.** This prevents a rating from being stored with any value outside the platform's defined half-point scale. Without this constraint, a bug in the application layer, a rounding error, or a direct database write from a different code path (an import script, an admin tool, a future integration) could insert a value like 3.7 or 4.3 — a rating that looks plausible but does not correspond to any option a user could actually select in the interface. Because `average_score` is computed as an aggregate over these values, even one such invalid row would quietly skew the average for that movie in a way that would be difficult to trace back to its source.

## Design Change from Unit 1: `average_score`

In the Unit 1 ERD and write-up, `average_score` was modeled as a stored, denormalized column on Movies, intended to be kept in sync with a trigger whenever a related row in `Ratings` changed. Working through Unit 2's guidance on derived attributes led me to reconsider this decision. The default guidance is that a value which can be computed from existing data should not be duplicated in storage unless there is a specific, measured performance problem justifying it, and this schema has no such measured bottleneck. Additionally, `average_score` cannot be implemented as a `GENERATED ALWAYS AS (...) STORED` column, since that PostgreSQL feature only computes from other columns in the same row and cannot aggregate across a different table.

For these reasons, `average_score` has been removed entirely from the `movies` table in `schema.sql`. It is now treated as a derived attribute, computed at query time:

```sql
SELECT title_id, title, AVG(score) AS average_score
FROM movies
LEFT JOIN ratings USING (title_id)
GROUP BY title_id, title;
```

The `LEFT JOIN` ensures a movie with no ratings still appears in the result, with `average_score` as `NULL`, consistent with the original Unit 1 domain rule that a movie without ratings has no average yet. The ERD has been updated to reflect this: `average_score` now appears as a dashed-border oval on Movies, indicating it is computed rather than stored.

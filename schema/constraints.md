# Task 1.3 — Integrity Constraints

## Foreign Key Constraints and ON DELETE Behavior

| # | Foreign Key | References | ON DELETE | Justification |
|---|---|---|---|---|
| FK1 | `Ratings.Account_ID` | `Users.Account_ID` | **CASCADE** | When a user's account is deleted, their ratings are deleted with it. This keeps `Movies.average_score` a true reflection of currently active users' opinions, rather than being inflated or skewed by ratings from accounts that no longer exist. |
| FK2 | `Ratings.Title_ID` | `Movies.Title_ID` | **CASCADE** | Movies has an `is_active` flag specifically for removing a title from listings without deleting it, so ratings are preserved across a temporary delisting. A hard `DELETE` on Movies is reserved for rare cases such as correcting a duplicate or erroneous entry. In that case, any ratings tied to the erroneous row are equally invalid and should be removed with it. |
| FK3 | `Movie_Genre.Title_ID` | `Movies.Title_ID` | **CASCADE** | A `Movie_Genre` row records a genre tag about a specific movie. It has no independent meaning once the movie it describes no longer exists, so it should be removed along with the movie. |
| FK4 | `Movie_Genre.Genre_ID` | `Genre.Genre_ID` | **RESTRICT** | Deleting a genre is a rare, platform-wide structural change that would silently untag every movie associated with it (potentially hundreds of rows in a single operation.) RESTRICT forces an explicit cleanup step (reassigning or removing those tags first) before such a disruptive, low-frequency action is allowed to proceed. |

## Other Integrity Constraints

**Users**
- `Account_ID`: `NOT NULL`, `UNIQUE`, `CHECK (account_id > 0)` — guarantees every account has a valid, non-null surrogate identifier.
- `Username`: `NOT NULL`, `UNIQUE` — no two accounts may share a username.
- `Email`: `NOT NULL`, `UNIQUE` — no two accounts may share an email address, and every account must have one on file.

**Movies**
- `Title_ID`: `NOT NULL`, `UNIQUE`, `CHECK (title_id > 0)`.
- `duration_minutes`: `NOT NULL`, `CHECK (duration_minutes > 0)` — a movie cannot have a zero or negative runtime.
- `average_score`: nullable by design — a movie with no ratings yet has no average to report. Maintained as a denormalized value, recalculated whenever a related row in `Ratings` is inserted, updated, or deleted.
- `is_active`: `NOT NULL`, `DEFAULT TRUE` — every movie must have a defined active/delisted state; a nullable flag would introduce an ambiguous third state.

**Ratings**
- `Score`: `NOT NULL`, `CHECK (score IN (0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0))` — restricts scores to the platform's defined half-point rating scale, preventing invalid values (e.g., 3.7) from ever being stored regardless of which application or script performs the insert.
- Composite primary key `(Title_ID, Account_ID)` enforces that a user cannot hold more than one active rating for the same movie at a time.

**Genre**
- `Genre_ID`: `NOT NULL`, `UNIQUE`, `CHECK (genre_id > 0)`.
- `Genre_type`: `NOT NULL`, `UNIQUE` — no duplicate genre names.

**Movie_Genre**
- Composite primary key `(Title_ID, Genre_ID)` ensures a movie cannot be tagged with the same genre more than once.

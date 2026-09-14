# Task 1.1 — Relation Schemas

## Users

| Attribute | Domain | Constraints |
|---|---|---|
| **Account_ID** (PK) | Positive integer | NOT NULL, UNIQUE, CHECK (account_id > 0) |
| Username | String, alphanumeric, max 20 characters, no spaces | NOT NULL, UNIQUE |
| Email | String, max 100 characters | NOT NULL, UNIQUE |
| Joined_date | Date (yyyy-mm-dd) | NOT NULL |

**Primary Key:** `Account_ID`

---

## Movies

| Attribute | Domain | Constraints |
|---|---|---|
| **Title_ID** (PK) | Positive integer | NOT NULL, UNIQUE, CHECK (title_id > 0) |
| Title | String, alphanumeric, max 100 characters | NOT NULL |
| duration_minutes | Positive integer | NOT NULL, CHECK (duration_minutes > 0) |
| average_score | Decimal, 0.0–5.0, in increments of 0.5 | Nullable (a title with no ratings has no average yet) |
| is_active | Boolean | NOT NULL, DEFAULT TRUE |

**Primary Key:** `Title_ID`

---

## Ratings

| Attribute | Domain | Constraints |
|---|---|---|
| **Title_ID** (PK, FK → Movies.Title_ID) | Positive integer | NOT NULL |
| **Account_ID** (PK, FK → Users.Account_ID) | Positive integer | NOT NULL |
| Score | Decimal, one of: 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0 | NOT NULL, CHECK (score IN (0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0)) |
| Time_Rated | Date/timestamp (yyyy-mm-dd) — represents the most recent time this rating was set or updated | NOT NULL |

**Primary Key:** `(Title_ID, Account_ID)` — composite. A user has at most one active rating per movie; changing a rating updates this row rather than inserting a new one.

---

## Genre

| Attribute | Domain | Constraints |
|---|---|---|
| **Genre_ID** (PK) | Positive integer | NOT NULL, UNIQUE, CHECK (genre_id > 0) |
| Genre_type | String, alphanumeric, max 20 characters | NOT NULL, UNIQUE |

**Primary Key:** `Genre_ID`

---

## Movie_Genre

| Attribute | Domain | Constraints |
|---|---|---|
| **Title_ID** (PK, FK → Movies.Title_ID) | Positive integer | NOT NULL |
| **Genre_ID** (PK, FK → Genre.Genre_ID) | Positive integer | NOT NULL |

**Primary Key:** `(Title_ID, Genre_ID)` — composite, standard junction table pattern resolving the many-to-many relationship between Movies and Genre.

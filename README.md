# ex603-movie-database
# Movie Ratings Platform — Relational Schema Design

A relational database design for a movie/TV rating platform, where users rate titles, browse by genre, and see aggregate scores.

**Theme:** Movies

## Domain

This platform allows registered users to rate movies titles, browse titles by genre, and see an aggregate score for each title based on all user ratings. Each title can belong to multiple genres, and each genre can apply to many titles, so the relationship between them is many-to-many. Titles can also be marked as active or delisted, allowing a title to be temporarily removed from listings without losing its rating history.

The schema must answer several core questions the platform depends on: Who rated a given title, and what score did they give it? What is a title's current average score, based only on ratings from currently active users? Which genres does a given title belong to, and which titles belong to a given genre? Can a user update a rating they've already given, or does every rating attempt create a new record? And what should happen to a title's ratings and genre tags if that title (or a user, or a genre) is ever removed from the platform?

Answering these questions shaped the key design decisions in this project: composite primary keys for the Ratings and Movie_Genre relations (since both represent relationships between two other entities rather than standalone things), an `is_active` flag on Movies to distinguish "temporarily delisted" from "permanently deleted," and a set of ON DELETE behaviors that reflect how disruptive and how frequent each kind of deletion realistically is.

## Entity Relationship Diagram

![ERD](schema/erd.png)

## Repository Structure

- `/schema/erd.png` — Exported ERD (Task 1.2)
- `/schema/schema-definition.md` — Relation schemas, attributes, domains, and primary keys (Task 1.1)
- `/schema/constraints.md` — Integrity constraints and ON DELETE justifications (Task 1.3)
- `/analysis/unit1.md` — Modelling justification and reflection (Task 1.4)

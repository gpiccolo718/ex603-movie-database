-- ==================================================
-- EX 603 Assignment 2 - schema.sql
-- Theme: Movie Streaming
-- Author: Gabriella Piccolo
-- Target: PostgreSQL 14+
-- ==================================================
-- Reset

DROP TABLE IF EXISTS movie_genre CASCADE;
DROP TABLE IF EXISTS genre CASCADE;
DROP TABLE IF EXISTS ratings CASCADE;
DROP TABLE IF EXISTS movies CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- 1. users - no dependencies, created first.
CREATE TABLE users (
    account_id  INT GENERATED ALWAYS AS IDENTITY,
    username    VARCHAR(20)  NOT NULL,
    email       VARCHAR(254) NOT NULL,
    joined_date DATE         NOT NULL,
    CONSTRAINT pk_users PRIMARY KEY (account_id),
    CONSTRAINT uq_users_username UNIQUE (username),
    CONSTRAINT uq_users_email UNIQUE (email)
);

-- 2. movies - no dependencies, created second.
CREATE TABLE movies (
    title_id            INT GENERATED ALWAYS AS IDENTITY,
    title               VARCHAR(100) NOT NULL,
    duration_minutes    INT NOT NULL,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_movies PRIMARY KEY (title_id),
    CONSTRAINT chk_movies_duration_min CHECK (duration_minutes > 0)
);

-- 3. ratings - depends on users and movies; must be created after both.
CREATE TABLE ratings (
    title_id    INT NOT NULL,
    account_id  INT NOT NULL,
    score       NUMERIC(2, 1) NOT NULL,
    time_rated  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_ratings PRIMARY KEY (title_id, account_id),
    CONSTRAINT chk_ratings_score CHECK (score IN (0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0)),
    CONSTRAINT fk_ratings_movies FOREIGN KEY (title_id) REFERENCES movies(title_id) ON DELETE CASCADE,
    CONSTRAINT fk_ratings_users FOREIGN KEY (account_id) REFERENCES users(account_id) ON DELETE CASCADE
);

-- 4. genre - no dependencies, created before movie_genre needs it.
CREATE TABLE genre (
    genre_id    INT GENERATED ALWAYS AS IDENTITY,
    genre_type  VARCHAR(20) NOT NULL,
    CONSTRAINT pk_genre PRIMARY KEY (genre_id),
    CONSTRAINT uq_genre_type UNIQUE (genre_type)
);

-- 5. movie_genre - junction table; depends on movies and genre, created last.
CREATE TABLE movie_genre (
    title_id INT NOT NULL,
    genre_id INT NOT NULL,
    CONSTRAINT pk_movie_genre PRIMARY KEY (title_id, genre_id),
    CONSTRAINT fk_movie_genre_movies FOREIGN KEY (title_id) REFERENCES movies(title_id) ON DELETE CASCADE,
    CONSTRAINT fk_movie_genre_genre FOREIGN KEY (genre_id) REFERENCES genre(genre_id) ON DELETE RESTRICT
);


-- 01_schema.sql
-- K-Drama database (Top 100 Korean dramas). Run this file first.

drop table if exists drama_cast, drama_genres, actors, genres, dramas, raw_dramas cascade;

-- Staging table: raw CSV values exactly as they appear in the file
create table raw_dramas (
    name           text,
    release_year   int,
    episodes       int,
    duration       text,            -- e.g. '1 hr. 30 min.'
    content_rating text,
    cast_text      text,            -- kept as in the CSV, not used further
    genre_text     text,            -- 'Romance, Comedy, ...'
    rank_text      text,            -- '#1'
    rating         numeric(2,1)
);

-- Clean tables
create table dramas (
    drama_id       serial primary key,
    title          varchar(150) not null,
    release_year   int not null,
    episodes       int not null check (episodes > 0),
    duration_min   int not null,
    content_rating varchar(60),
    rating         numeric(2,1) not null,
    rank_position  int not null unique
);

create table genres (
    genre_id   serial primary key,
    genre_name varchar(50) not null unique
);

-- Many-to-many: dramas <-> genres
create table drama_genres (
    drama_id int not null references dramas(drama_id) on delete cascade,
    genre_id int not null references genres(genre_id) on delete cascade,
    primary key (drama_id, genre_id)
);

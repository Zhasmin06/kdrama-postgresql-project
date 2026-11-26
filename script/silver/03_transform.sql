-- 03_transform.sql
-- Cleans raw_dramas and fills the final tables. Run after 02_load_raw.sql.

-- 1) dramas: strip '#' from rank, convert 'N hr. N min.' to minutes, trim text
insert into dramas (title, release_year, episodes, duration_min, content_rating, rating, rank_position)
select trim(name),
       release_year,
       episodes,
       coalesce(substring(duration from '(\d+) hr')::int, 0) * 60
         + coalesce(substring(duration from '(\d+) min')::int, 0),
       trim(content_rating),
       rating,
       replace(rank_text, '#', '')::int
from raw_dramas
order by replace(rank_text, '#', '')::int;

-- 2) genres: split 'Romance, Comedy' into separate rows
insert into genres (genre_name)
select distinct trim(g)
from raw_dramas, unnest(string_to_array(genre_text, ',')) as g
order by 1;

-- 3) drama_genres (rank is unique, so we join on it: two dramas are both called 'Kingdom')
insert into drama_genres (drama_id, genre_id)
select distinct d.drama_id, g.genre_id
from raw_dramas r
join dramas d on d.rank_position = replace(r.rank_text, '#', '')::int
cross join lateral unnest(string_to_array(r.genre_text, ',')) as x(genre_name)
join genres g on g.genre_name = trim(x.genre_name);

-- Check: row counts in every table
select 'dramas' as tbl, count(*) from dramas
union all select 'genres', count(*) from genres
union all select 'drama_genres', count(*) from drama_genres;

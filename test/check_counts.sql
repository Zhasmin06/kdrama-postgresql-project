-- check_counts.sql
-- run after the load: every table should have the expected number of rows

select 'raw_dramas' as tbl, count(*) as rows_found, 100 as rows_expected from raw_dramas
union all select 'dramas', count(*), 100 from dramas
union all select 'genres', count(*), 26 from genres
union all select 'drama_genres', count(*), 396 from drama_genres;

-- every drama must have at least one genre (expected result: 0 rows)
select d.title
from dramas d
left join drama_genres dg on dg.drama_id = d.drama_id
where dg.drama_id is null;

-- ranks must be unique and run from 1 to 100 (expected: 100, 1, 100)
select count(distinct rank_position), min(rank_position), max(rank_position) from dramas;

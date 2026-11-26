-- 04_queries.sql
-- Analysis queries for the K-Drama database. Run after 03_transform.sql.
-- Tip: put the cursor inside one query and press Ctrl+Enter to run just that query.

-- =====================================================================
-- PART 1. Basic: WHERE, ORDER BY, DISTINCT, aggregate functions
-- =====================================================================

-- Q1. Dramas released in 2019 or later with rating 8.8 or higher, best first
select title, release_year, rating
from dramas
where release_year >= 2019
  and rating >= 8.8
order by rating desc, title;

-- Q2. Which content ratings exist in the data? (DISTINCT)
select distinct content_rating
from dramas
order by content_rating;

-- Q3. General statistics (aggregate functions)
select count(*)                    as total_dramas,
       round(avg(rating), 2)       as avg_rating,
       min(rating)                 as min_rating,
       max(rating)                 as max_rating,
       round(avg(episodes), 1)     as avg_episodes,
       max(episodes)               as max_episodes
from dramas;

-- =====================================================================
-- PART 2. GROUP BY and HAVING
-- =====================================================================

-- Q4. Number of dramas and average rating for each release year
select release_year,
       count(*)              as drama_count,
       round(avg(rating), 2) as avg_rating
from dramas
group by release_year
order by release_year;

-- Q5. Only the years that have more than 10 dramas in the top 100 (HAVING)
select release_year, count(*) as drama_count
from dramas
group by release_year
having count(*) > 10
order by drama_count desc;

-- =====================================================================
-- PART 3. JOINs (through the link tables)
-- =====================================================================

-- Q6. Number of dramas and average rating per genre (3 tables joined)
select g.genre_name,
       count(*)              as drama_count,
       round(avg(d.rating), 2) as avg_rating
from genres g
join drama_genres dg on dg.genre_id = g.genre_id
join dramas d        on d.drama_id  = dg.drama_id
group by g.genre_name
order by drama_count desc;

-- Q7. Genres that appear in at least 20 dramas of the top 100
select g.genre_name, count(*) as drama_count
from genres g
join drama_genres dg on dg.genre_id = g.genre_id
group by g.genre_name
having count(*) >= 20
order by drama_count desc, g.genre_name;

-- Q8. Dramas with the largest number of genres
select d.title, count(*) as genre_count
from dramas d
join drama_genres dg on dg.drama_id = d.drama_id
group by d.title, d.drama_id
order by genre_count desc, d.title
limit 10;

-- =====================================================================
-- PART 4. Subqueries
-- =====================================================================

-- Q9. Dramas with a rating above the average rating of all dramas
select title, rating
from dramas
where rating > (select avg(rating) from dramas)
order by rating desc, title;

-- Q10. Dramas that have the genre 'Thriller' (IN with a subquery)
select title, rating
from dramas
where drama_id in (select dg.drama_id
                   from drama_genres dg
                   join genres g on g.genre_id = dg.genre_id
                   where g.genre_name = 'Thriller')
order by rating desc, title;

-- =====================================================================
-- PART 5. CASE
-- =====================================================================

-- Q11. Group dramas into rating categories and count them
select case
           when rating >= 9.0 then 'Masterpiece'
           when rating >= 8.7 then 'Great'
           else 'Good'
       end as category,
       count(*) as drama_count
from dramas
group by 1
order by drama_count desc;

-- =====================================================================
-- PART 6. Set operations: UNION, INTERSECT, EXCEPT
-- =====================================================================

-- Q12. UNION: dramas that are Romance OR Comedy (duplicates removed)
select d.title
from dramas d
join drama_genres dg on dg.drama_id = d.drama_id
join genres g        on g.genre_id  = dg.genre_id
where g.genre_name = 'Romance'
union
select d.title
from dramas d
join drama_genres dg on dg.drama_id = d.drama_id
join genres g        on g.genre_id  = dg.genre_id
where g.genre_name = 'Comedy'
order by title;

-- Q13. INTERSECT: dramas that are both Romance AND Comedy
select d.title
from dramas d
join drama_genres dg on dg.drama_id = d.drama_id
join genres g        on g.genre_id  = dg.genre_id
where g.genre_name = 'Romance'
intersect
select d.title
from dramas d
join drama_genres dg on dg.drama_id = d.drama_id
join genres g        on g.genre_id  = dg.genre_id
where g.genre_name = 'Comedy'
order by title;

-- Q14. EXCEPT: Romance dramas that are NOT Comedy
select d.title
from dramas d
join drama_genres dg on dg.drama_id = d.drama_id
join genres g        on g.genre_id  = dg.genre_id
where g.genre_name = 'Romance'
except
select d.title
from dramas d
join drama_genres dg on dg.drama_id = d.drama_id
join genres g        on g.genre_id  = dg.genre_id
where g.genre_name = 'Comedy'
order by title;

-- =====================================================================
-- PART 7. Window functions
-- =====================================================================

-- Q15. ROW_NUMBER vs RANK vs DENSE_RANK on the same column.
-- Many dramas share the same rating, so you can see how the three differ on ties.
select title,
       rating,
       row_number() over (order by rating desc) as row_num,
       rank()       over (order by rating desc) as rank_num,
       dense_rank() over (order by rating desc) as dense_rank_num
from dramas
order by rating desc, title
limit 15;

-- Q16. ROW_NUMBER + PARTITION BY: the best drama of each release year
with ranked as (
    select release_year, title, rating,
           row_number() over (partition by release_year
                              order by rating desc, rank_position) as rn
    from dramas
)
select release_year, title, rating
from ranked
where rn = 1
order by release_year;

-- Q17. RANK + PARTITION BY: top 3 dramas inside each genre
with genre_rank as (
    select g.genre_name, d.title, d.rating,
           rank() over (partition by g.genre_name
                        order by d.rating desc) as rnk
    from dramas d
    join drama_genres dg on dg.drama_id = d.drama_id
    join genres g        on g.genre_id  = dg.genre_id
)
select genre_name, title, rating, rnk
from genre_rank
where rnk <= 3
order by genre_name, rnk, title;

-- Q18. Aggregate as a window function: how far each drama is from its year's average
select title,
       release_year,
       rating,
       round(avg(rating) over (partition by release_year), 2)          as year_avg,
       round(rating - avg(rating) over (partition by release_year), 2) as diff_from_year_avg
from dramas
order by release_year, diff_from_year_avg desc;

-- =====================================================================
-- PART 8. INSERT, UPDATE, DELETE (adds a test row, changes it, removes it)
-- =====================================================================

-- Q19. INSERT a new drama
insert into dramas (title, release_year, episodes, duration_min, content_rating, rating, rank_position)
values ('My Test Drama', 2024, 12, 60, '15+ - Teens 15 or older', 7.5, 101);

-- Q20. UPDATE its rating
update dramas
set rating = 8.0
where title = 'My Test Drama';

-- Check the row
select * from dramas where title = 'My Test Drama';

-- Q21. DELETE it again
delete from dramas
where title = 'My Test Drama';

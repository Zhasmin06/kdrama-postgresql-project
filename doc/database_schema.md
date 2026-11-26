# Database schema

```
dramas                      drama_genres                genres
------                      ------------                ------
drama_id (PK)  <----------  drama_id (PK, FK)           genre_id (PK)
title                       genre_id (PK, FK)  ------>  genre_name (unique)
release_year
episodes
duration_min
content_rating
rating
rank_position (unique)
```

- `dramas` and `genres` have a many-to-many relationship: one drama has several genres, one genre belongs to many dramas.
- `drama_genres` is the link table. Its primary key is the pair `(drama_id, genre_id)`, so the same pair cannot be stored twice.
- `raw_dramas` is a temporary staging table with the CSV data exactly as in the file.

## Data cleaning steps

| Problem in the CSV | Fix in `script/silver/03_transform.sql` |
|---|---|
| Rank is text (`#1`) | `replace(rank_text, '#', '')::int` |
| Duration is text (`1 hr. 30 min.`) | `substring(...)` extracts hours and minutes, converted to minutes |
| Genres are in one cell (`Romance, Comedy`) | `string_to_array` + `unnest` split them into rows |
| Extra spaces around text | `trim(...)` |
| Two different dramas are both called "Kingdom" | tables are joined by the unique `rank_position`, not by title |

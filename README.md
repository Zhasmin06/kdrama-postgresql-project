# Top 100 Korean Dramas: PostgreSQL Database

Final project for the University SQL course (Week 10).

## About the project

This project builds a small PostgreSQL database from a public dataset of the 100 highest-rated Korean dramas (data from MyDramaList as of December 30, 2021) and analyzes it with SQL: ratings by year and genre, best dramas per category, genre combinations, and more.

## Data source

- **Dataset:** Top 100 Korean Drama (MyDramaList) on Kaggle, file `top100_kdrama.csv`
- **Author:** Chanon Charuchinda (Kaggle user: chanoncharuchinda)
- **Link:** https://www.kaggle.com/datasets/chanoncharuchinda/top-100-korean-drama-mydramalist
- **License:** CC0 1.0 Universal (Public Domain Dedication), https://creativecommons.org/publicdomain/zero/1.0/
- Original data comes from MyDramaList.

The original CSV is included in `dataset/top100_kdrama.csv`.

## Database structure

| Table | Description |
|---|---|
| `raw_dramas` | Temporary staging table with the CSV data exactly as it appears in the file |
| `dramas` | One row per drama: title, release year, episodes, duration in minutes, content rating, rating, rank |
| `genres` | List of 26 unique genres |
| `drama_genres` | Link table (many-to-many) between dramas and genres |

A drama can have many genres and a genre can belong to many dramas, so they are connected through `drama_genres` (foreign keys to `dramas.drama_id` and `genres.genre_id`). More details and the cleaning steps are in [doc/database_schema.md](doc/database_schema.md).

## Repository structure

```
kdrama-postgresql-project/
├── dataset/
│   └── top100_kdrama.csv        original data from Kaggle
├── doc/
│   └── database_schema.md       tables, relationships, data cleaning steps
├── script/
│   ├── init_database.sql        creates all tables
│   ├── bronze/
│   │   └── 02_load_raw.sql      loads the raw CSV data into raw_dramas
│   ├── silver/
│   │   └── 03_transform.sql     cleans the data and fills dramas, genres, drama_genres
│   ├── gold/
│   │   └── 04_queries.sql       21 analysis queries
│   └── kdrama_all.sql           all scripts in one file
├── test/
│   └── check_counts.sql         checks that the data loaded correctly
└── README.md
```

The scripts follow three layers: **bronze** (raw data), **silver** (cleaned data) and **gold** (analysis).

## How to run

1. Install PostgreSQL and a client such as DBeaver or pgAdmin.
2. Create a database: `create database kdrama;` and connect to it.
3. Run the scripts in order: `script/init_database.sql`, `script/bronze/02_load_raw.sql`, `script/silver/03_transform.sql` (or just `script/kdrama_all.sql`).
4. Run `test/check_counts.sql`: it should show 100 dramas, 26 genres and 396 drama-genre links.
5. Run the queries from `script/gold/04_queries.sql` one at a time.

## Main queries

| Topic | Queries | Example question |
|---|---|---|
| WHERE, ORDER BY, DISTINCT, aggregates | Q1-Q3 | Which dramas since 2019 have a rating of at least 8.8? |
| GROUP BY, HAVING | Q4-Q5 | In which years were more than 10 dramas released? |
| JOIN | Q6-Q8 | How many dramas and what average rating does each genre have? |
| Subqueries | Q9-Q10 | Which dramas are rated above the average? |
| CASE | Q11 | How many "Masterpiece", "Great" and "Good" dramas are there? |
| UNION, INTERSECT, EXCEPT | Q12-Q14 | Which dramas are Romance and Comedy at the same time? |
| Window functions | Q15-Q18 | What are the top 3 dramas in each genre? What is the best drama of each year? |
| INSERT, UPDATE, DELETE | Q19-Q21 | Add, change and remove a test drama |

## Tools

PostgreSQL, DBeaver. AI assistance (Claude) was used for ideas, code drafting and debugging, as allowed by the course policy.

## Author

Serik Zhasmin, Suleyman Demirel University

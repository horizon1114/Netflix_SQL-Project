# Netflix Movies and TV Shows Data Analysis using PostgGres SQL

![](https://github.com/horizon1114/Netflix_SQL-Project/blob/main/logo.png)

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema
```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;
```

**Objective:** Determine the distribution of content types on Netflix.
### 2. Find the Most Common Rating for Movies and TV Shows

```sql
SELECT
     type,
     title,
     rating
 FROM
 (
     SELECT
     type,
     rating,
     count(*),
     RANK() OVER(PARTITION BY type ORDER BY count(*) DESC) as ranking
from netflix
group by type,rating
 ) as t1
 where ranking=1;
```
**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT
title
from netflix
where type='Movie' and release_year=2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT
  UNNEST(string_to_array(country,',','')) as new_country,
  count(show_id) as total_content
from netflix
group by new_country
order by total_content DESC
limit 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT 
    title,
    CAST(REPLACE(duration, ' min', '') AS INTEGER) AS duration_minutes
FROM 
    netflix
WHERE 
    type = 'Movie' 
    AND duration IS NOT NULL
ORDER BY 
    duration_minutes DESC
LIMIT 1;
```
**Objective:** Find the movie with the longest duration.

### 6. Find content added in the last 5 years

```sql
select 
    title,
    date_added
from netflix
where TO_DATE(date_added,'Month DD,YYYY')>=CURRENT_DATE- INTERVAL'5 Years';
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Count the Number of CONTENT Items in each Genre

```sql
SELECT
    UNNEST(STRING_TO_ARRAY(listed_in,',','')) as genre,
    count(*)
from netflix
group by genre;
```

**Objective:** Count the number of content items in each genre.

### 8.  List All TV Shows with More Than 5 Seasons
```sql
SELECT
title,
duration
from netflix
where type= 'TV Show'
and CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Find the Average number of Contents released in India per year and show the top 5 years
```sql
SELECT
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
    COUNT(*) AS yearly_content,
    ROUND(
        COUNT(*)::NUMERIC /
        (SELECT COUNT(*) 
         FROM netflix 
         WHERE country = 'India')::NUMERIC
        * 100,
        2
    ) AS avg_content
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 3 DESC
limit 5;
```
Objective:** Calculate and rank years by the average number of content releases by India.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.

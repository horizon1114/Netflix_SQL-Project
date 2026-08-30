CREATE TABLE netflix
(
    show_id VARCHAR(6),
    type VARCHAR(10),
    title VARCHAR(150),
    director VARCHAR(250),
    casts VARCHAR(1000),
    country VARCHAR(150),
    date_added VARCHAR(50),
    release_year INT,
    rating VARCHAR(20),
    duration VARCHAR(100),
    listed_in VARCHAR(100),
    description VARCHAR(500)
);

-- 1.count the number of movies vs tv shows
select 
    type,
    count(*) as total
from netflix
group by type;

 -- 2.find the most common rating for movies and tv shows
 SELECT
 type,
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
 WHERE ranking=1;

-- 3.list all movies released in a specific year

SELECT
title
from netflix
where type='Movie' and release_year=2020;

--4. find the top 5 countries with the most content on netflix
SELECT
  UNNEST(string_to_array(country,',','')) as new_country,
  count(show_id) as total_content
from netflix
group by new_country
order by total_content DESC
limit 5;

--5.identify the longest movie
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

--6.find content added in the last 5 years
select 
    title,
    date_added
from netflix
where TO_DATE(date_added,'Month DD,YYYY')>=CURRENT_DATE- INTERVAL'5 Years';

--7.count the number of CONTENT items in each genre
SELECT
    UNNEST(STRING_TO_ARRAY(listed_in,',','')) as genre,
    count(*)
from netflix
group by genre;

--8.list all the tv shows with more than 5 seasons
SELECT
title,
duration
from netflix
where type= 'TV Show'
and CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5;

--9. find the average number of contents released in India per year and show the top 5 years
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

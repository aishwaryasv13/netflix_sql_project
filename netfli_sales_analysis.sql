CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);

SELECT * FROM netflix;

-- Count the number of Movies vs TV Shows
SELECT
	type,
	COUNT(*) as total_count
FROM netflix
GROUP BY 1

-- Find the most common rating for movies and TV shows
SELECT
	type,
	rating
FROM

(SELECT 
	type,
	rating,
	COUNT(*),
	RANK()OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as Ranking
FROM netflix
GROUP BY 1,2
) as t1
WHERE
	Ranking = 1

-- List all movies released in a specific year (e.g., 2020)
SELECT 
	type,
	release_year
FROM netflix
WHERE 
	type = 'Movie'
	AND 
	release_year = 2020

-- Find the top 5 countries with the most content on Netflix
SELECT 
	UNNEST(STRING_TO_ARRAY(country,',')) as new_country_list,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- Identify the longest movie
SELECT
	type,
	title,
	duration
FROM netflix
WHERE
	type = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix)

-- Find content added in the last 5 years
SELECT 
	type,
	date_added
FROM netflix
WHERE
	TO_DATE(date_added,'Month DD YYYY') >= CURRENT_DATE - INTERVAL '5 years'

-- Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT 
	type,
	title,
	director_name
FROM
(
SELECT 
	*,
	UNNEST(STRING_TO_ARRAY(director, ',')) as director_name
FROM 
netflix
)
WHERE 
	director_name = 'Rajiv Chilaka'

-- List all TV shows with more than 5 seasons
SELECT 
	type,
	duration,
	title
FROM netflix
WHERE
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ',1) :: numeric  > 5 

-- Count the number of content items in each genre
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as content_items,
	COUNT(*) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC

-- Find each year and the average numbers of content release by India on netflix. 
-- Return top 5 year with highest avg content release !
SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
	COUNT(*) as yearly_content,
	ROUND(
COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India'):: numeric * 100,2
	) as avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC

-- List all movies that are documentaries
SELECT 
	type,
	title,
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as new_list
FROM netflix
WHERE listed_in = 'Documentaries'
	  AND 
	  type = 'Movie'

-- Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL

-- Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT
	UNNEST(STRING_TO_ARRAY(casts,',')) as actors,
	COUNT(*) as total_content
FROM netflix
WHERE country ILIKE '%india'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.
WITH new_table
AS
(
SELECT
*,
	CASE
	WHEN
		description ILIKE '%kill%'
		OR
		description ILIKE '%violence%' THEN 'Bad content'
		ELSE 'Good content'
	END category
FROM netflix
)
SELECT 
	category,
	COUNT(*)as total_content
FROM new_table
GROUP BY 1







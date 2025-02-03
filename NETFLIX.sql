-- NETFLIX PROJECT

DROP TABLE IF EXISTS netflix

CREATE TABLE netflix
(
		show_id varchar(5),
		type varchar(10),	
		title varchar(150),	
		director varchar(210),	
		casts varchar(800),	
		country	varchar(150),
		date_added varchar(50),	
		release_year int,	
		rating varchar(10),	
		duration varchar(15),	
		listed_in varchar(100),	
		description varchar(250)
)
--FOR CHECKING DATA CONTENT
SELECT * FROM netflix

SELECT
	COUNT(*) AS total_content 
FROM netflix

SELECT DISTINCT type FROM netflix

SELECT * FROM netflix

--1. Count the number of Movies vs TV Shows

SELECT 
	type,
	COUNT(*) as total_amount
FROM netflix
GROUP BY type

--2. Find the most common rating for movies and TV shows
--we cannot use MAX function on string(rating column)
SELECT
	type,
	rating
FROM
(
	SELECT
		type,
		rating,
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as RANKING
	FROM netflix
	GROUP BY type,rating
) 
WHERE 
	ranking=1

--3. List all movies released in a specific year (e.g., 2020)

SELECT * FROM netflix
WHERE 
	type='Movie'
	AND
	release_year =2020

--4. Find the top 5 countries with the most content on Netflix

SELECT 
	UNNEST(STRING_TO_ARRAY(country,','))as new_country
FROM netflix;
--above query if for checking result of subquery

--main query
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(country,','))) as new_country,
	COUNT(show_id) as TOTAL_CONTENT
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

--5. Identify the longest movie

WITH CTE AS
		(SELECT 
			title,
			cast(replace(duration,'min','') as INT) as TOTAL_DURATION
		FROM  netflix
		WHERE 
			type = 'Movie'
		ORDER BY TOTAL_DURATION DESC)
SELECT 
	title,
	TOTAL_DURATION
FROM CTE
WHERE TOTAL_DURATION =(SELECT MAX(TOTAl_DURATION) from CTE)
	
--6. Find content added in the last 5 years

SELECT 
	*
FROM netflix
WHERE 
	TO_DATE(date_added,'MONTH DD, YYYY') > CURRENT_DATE - INTERVAL '5 years'

--7. Find all the movies/TV shows by director 'Rajiv ChSLECT

SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'

--8. List all TV shows with more than 5 seasons

SELECT * FROM netflix
WHERE 
	type ='TV Show'
	AND
	SPLIT_PART(duration,' ',1):: NUMERIC > 5

--9. Count the number of content items in each genre

SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in,','))) AS GENRE,
	COUNT(show_id) as TOTAL_CONTENT
FROM netflix
GROUP BY 1
ORDER BY 2 DESC

--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release! 

SELECT 
	EXTRACT(Year FROM TO_DATE(date_added, 'Month,DD,YYYY')) as YEARR,
	COUNT(*),
	ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100,2) AS AVG_CONTENT_PER_YEAR
FROM netflix
WHERE country = 'India' 
GROUP BY 1
ORDER BY 3 DESC
LIMIT 5
-- IF WE DONT WANT TOP 5 AVG YEAR THEN REMOVE LIMIT (WHICH GIVE ALL YEARS AVERAGE)

--11. List all movies that are documentaries

SELECT * FROM netflix
WHERE 
	listed_in ILIKE '%Documentaries%'
	AND 
	type = 'Movie'

--12. Find all content without a director

SELECT * FROM netflix
WHERE 
	director IS NULL

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM netflix
WHERE 
	casts ILIKE '%Salman Khan%'
	AND
	release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10 

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(casts,','))) AS Actor,
	COUNT(*) AS MOVIES_APPEARED
FROM netflix
WHERE 
	country ILIKE '%India%'
	AND
	type = 'Movie'
GROUP BY 1
ORDER BY 2 DESC


--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

WITH CTE
AS
(
SELECT 
	* ,
	CASE 
		WHEN description ILIKE '% kill%' OR 
			description ILIKE '%violence%' THEN 'Bad_Content'
			ELSE 'Good Content'
		END AS category
FROM netflix
)
SELECT 
	category,
	COUNT(*) as total_content
FROM CTE
GROUP BY 1

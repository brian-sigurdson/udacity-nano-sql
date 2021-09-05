-- These queries are associated WITH the questions presented in the COUNTRY-LEVEL DETAIL section.

-- The first paragraph of part 3 of the document, COUNTRY-LEVEL DETAIL, states information about success stories,
-- but were not included in the preparation questions below, so I'm creating it now.

-- success stories
-- Which country increased forest area FROM 1990 to 2016?
-- What was the percentage change?
-- Which is the country WITH the next largest increase in forest area FROM 1990 to 2016?
-- What was the percentage change?
WITH sqkm_1990 AS
    (
        SELECT country_name, forest_area_sqkm AS forest_area_sqkm_1990
        FROM forestation
        WHERE year = 1990 AND country_name != 'World'
    ),
    sqkm_2016 AS
    (
        SELECT country_name, forest_area_sqkm AS forest_area_sqkm_2016
        FROM forestation
        WHERE year = 2016 AND country_name != 'World'
    )
SELECT sqkm_1990.country_name,
       ROUND((forest_area_sqkm_2016 - forest_area_sqkm_1990)::NUMERIC,2) AS sqkm_change,
       ROUND(((forest_area_sqkm_2016 - forest_area_sqkm_1990)/(forest_area_sqkm_1990))::NUMERIC * 100,2) AS percent_change
FROM sqkm_1990
INNER JOIN sqkm_2016 ON sqkm_1990.country_name = sqkm_2016.country_name
WHERE (forest_area_sqkm_2016 - forest_area_sqkm_1990) is not null
ORDER BY percent_change desc
LIMIT 2;

-- a. Which 5 countries saw the largest amount decrease in forest area FROM 1990 to 2016?
-- What was the difference in forest area for each?
WITH sqkm_1990 AS
    (
        SELECT country_name, forest_area_sqkm AS forest_area_sqkm_1990
        FROM forestation
        WHERE year = 1990 AND country_name != 'World'
    ),
    sqkm_2016 AS
    (
        SELECT country_name, forest_area_sqkm AS forest_area_sqkm_2016
        FROM forestation
        WHERE year = 2016 AND country_name != 'World'
    )
SELECT sqkm_1990.country_name, ROUND((forest_area_sqkm_2016 - forest_area_sqkm_1990)::NUMERIC,2) AS sqkm_change
FROM sqkm_1990
INNER JOIN sqkm_2016 ON sqkm_1990.country_name = sqkm_2016.country_name
ORDER BY sqkm_change
LIMIT 5;

-- b. Which 5 countries saw the largest percent decrease in forest area FROM 1990 to 2016?
-- What was the percent change to 2 decimal places for each?
WITH sqkm_1990 AS
    (
        SELECT country_name, region, forest_area_sqkm AS forest_area_sqkm_1990
        FROM forestation
        WHERE year = 1990 AND country_name != 'World'
    ),
    sqkm_2016 AS
    (
        SELECT country_name, region, forest_area_sqkm AS forest_area_sqkm_2016
        FROM forestation
        WHERE year = 2016 AND country_name != 'World'
    )
SELECT sqkm_1990.country_name, sqkm_1990.region,
       ROUND((forest_area_sqkm_2016 - forest_area_sqkm_1990)::NUMERIC,2) AS sqkm_change,
       ROUND(((forest_area_sqkm_2016 - forest_area_sqkm_1990)/(forest_area_sqkm_1990))::NUMERIC * 100,2) AS percent_change
FROM sqkm_1990
INNER JOIN sqkm_2016 ON sqkm_1990.country_name = sqkm_2016.country_name
WHERE (forest_area_sqkm_2016 - forest_area_sqkm_1990) is not null
-- ORDER BY sqkm_change
ORDER BY percent_change
LIMIT 5;

-- c. If countries were grouped BY percent forestation in quartiles, which GROUP had the most countries in it in 2016?
-- NOTE:  Per the grading rubric, we need to implement a case statement for this solution.
WITH quartile_sums_2016 AS
    (
        SELECT
            case
                when percent_forest <= 25.00 then 'Q1'
                when percent_forest > 25.00 AND percent_forest <= 50.00 then 'Q2'
                when percent_forest > 50.00 AND percent_forest <= 75.00 then 'Q3'
                when percent_forest > 75.00 then 'Q4'
            END AS quartile
        FROM forestation
        WHERE year = 2016 AND country_code != 'WLD' AND percent_forest IS NOT NULL
    )
SELECT quartile, count(*) as quartile_count
FROM quartile_sums_2016
group by 1
order by 1;

-- d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.
SELECT country_name
FROM forestation
WHERE year = 2016 AND percent_forest > 75.00;

-- e. How many countries had a percent forestation higher than the United States in 2016?
-- NOTE:  This is a self-INNER JOIN query.
SELECT COUNT(*)
FROM forestation a
INNER JOIN forestation b ON a.year = b.year AND a.country_code = b.country_code
WHERE a.year = 2016 AND a.percent_forest >
                        (
                            SELECT percent_forest
                            FROM forestation
                            WHERE year = 2016 AND country_code = 'USA'
                        )
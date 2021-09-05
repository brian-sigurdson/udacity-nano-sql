-- These queries are associated WITH the questions presented in the Global Situation section.

-- a. What was the total forest area (in sq km) of the world in 1990?
-- Please keep in mind that you can use the country record denoted AS “World" in the region table.
SELECT forest_area_sqkm AS forest_area_sqkm_1990
FROM forestation
WHERE year = 1990 AND country_code = 'WLD';

-- b. What was the total forest area (in sq km) of the world in 2016?
-- Please keep in mind that you can use the country record in the table is denoted AS “World.”
SELECT forest_area_sqkm AS forest_area_sqkm_2016
FROM forestation
WHERE year = 2016 AND country_code = 'WLD';

-- c. What was the change (in sq km) in the forest area of the world FROM 1990 to 2016?
WITH sqkm_1990 AS
    (
        SELECT country_code, forest_area_sqkm AS forest_area_sqkm_1990
        FROM forestation
        WHERE year = 1990 AND country_code = 'WLD'
    ),
    sqkm_2016 AS
    (
        SELECT country_code, forest_area_sqkm AS forest_area_sqkm_2016
        FROM forestation
        WHERE year = 2016 AND country_code = 'WLD'
    )
SELECT sqkm_1990.country_code,
       forest_area_sqkm_1990,
       forest_area_sqkm_2016,
       forest_area_sqkm_2016 - forest_area_sqkm_1990 AS sqkm_change
FROM sqkm_1990
INNER JOIN sqkm_2016 ON sqkm_1990.country_code = sqkm_2016.country_code;

-- d. What was the percent change in forest area of the world between 1990 AND 2016?
WITH sqkm_1990 AS
    (
        SELECT country_code, forest_area_sqkm AS forest_area_sqkm_1990
        FROM forestation
        WHERE year = 1990 AND country_code = 'WLD'
    ),
    sqkm_2016 AS
    (
        SELECT country_code, forest_area_sqkm AS forest_area_sqkm_2016
        FROM forestation
        WHERE year = 2016 AND country_code = 'WLD'
    )
SELECT sqkm_1990.country_code,
       forest_area_sqkm_1990,
       forest_area_sqkm_2016,
       forest_area_sqkm_2016 - forest_area_sqkm_1990 AS sqkm_change,
       ROUND((((forest_area_sqkm_2016 - forest_area_sqkm_1990) / forest_area_sqkm_1990)::NUMERIC * 100),2) AS percentage_change
FROM sqkm_1990
INNER JOIN sqkm_2016 ON sqkm_1990.country_code = sqkm_2016.country_code;

-- e. If you compare the amount of forest area lost between 1990 AND 2016, to which country's total area in 2016 is it closest to?
-- Find the first country whose land area is more than the forest area lost between 1990 AND 2016, when the land areas
-- BY country are in descending ORDER.
SELECT country_name, ROUND(total_area_sqkm::NUMERIC,2)
FROM forestation
WHERE year = 2016 AND country_code != 'WLD' AND total_area_sqkm <
                      (
                          -- calculate the forest area lost between 1990 AND 2016
                          SELECT abs(sqkm_change)
                          FROM (
                                   WITH sqkm_1990 AS
                                            (
                                                SELECT country_code, forest_area_sqkm AS forest_area_sqkm_1990
                                                FROM forestation
                                                WHERE year = 1990
                                                  AND country_code = 'WLD'
                                            ),
                                        sqkm_2016 AS
                                            (
                                                SELECT country_code, forest_area_sqkm AS forest_area_sqkm_2016
                                                FROM forestation
                                                WHERE year = 2016
                                                  AND country_code = 'WLD'
                                            )
                                   SELECT forest_area_sqkm_2016 - forest_area_sqkm_1990 AS sqkm_change
                                   FROM sqkm_1990
                                       INNER JOIN sqkm_2016 ON sqkm_1990.country_code = sqkm_2016.country_code
                               ) AS sub
                      )
ORDER BY total_area_sqkm desc
LIMIT 1
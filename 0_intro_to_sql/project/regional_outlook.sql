-- This query is associated with the questions presented in the REGIONAL OUTLOOK section.

-- Create a table that shows the Regions AND their percent forest area
--      (sum of forest area divided BY SUM of land area) in 1990 and 2016. (Note that 1 sq mi = 2.59 sq km).
--      Based ON the table you created, answer the following questions.
WITH sqkm_1990 AS
    (
        SELECT region,
               SUM(forest_area_sqkm) AS sum_forest_area_sqkm_1990,
               SUM(total_area_sqkm) AS sum_land_area_sqkm_1990,
               ROUND((SUM(forest_area_sqkm) / SUM(total_area_sqkm))::NUMERIC * 100,2) AS percentage_forest_area_1990
        FROM forestation
        WHERE year = 1990
        GROUP BY 1
    ),
    sqkm_2016 AS
    (
        SELECT region,
               SUM(forest_area_sqkm) AS sum_forest_area_sqkm_2016,
               SUM(total_area_sqkm) AS sum_land_area_sqkm_2016,
               ROUND((SUM(forest_area_sqkm) / SUM(total_area_sqkm))::NUMERIC * 100,2) AS percentage_forest_area_2016
        FROM forestation
        WHERE year = 2016
        GROUP BY 1
    )
SELECT sqkm_1990.region,
       percentage_forest_area_1990,
       percentage_forest_area_2016,
       percentage_forest_area_2016 - percentage_forest_area_1990 AS percentage_forest_area_change
FROM sqkm_1990
INNER JOIN sqkm_2016 ON sqkm_1990.region = sqkm_2016.region
-- ORDER BY sqkm_forest_area_change
ORDER BY percentage_forest_area_1990


-- a. What was the percent forest of the entire world in 2016?
-- 31.38
-- Which region had the HIGHEST percent forest in 2016, AND which had the LOWEST, to 2 decimal places?
-- Highest = Latin America & Caribbean, Lowest = Middle East & North Africa

-- b. What was the percent forest of the entire world in 1990?
-- 32.42
-- Which region had the HIGHEST percent forest in 1990, AND which had the LOWEST, to 2 decimal places?
-- Highest = Latin America & Caribbean, Lowest = Middle East & North Africa

-- c. Based ON the table you created, which regions of the world DECREASED in forest area FROM 1990 to 2016?
-- Latin America & Caribbean, Sub-Saharan Africa
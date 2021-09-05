-- These queries are associated with the RECOMMENDATIONS section.

-- Income Group: count, forest area, land area, percent forest
WITH tbl_1990 AS
    (
        SELECT income_group,
            COUNT(*) AS COUNT,
            ROUND(SUM(forest_area_sqkm)::NUMERIC,2) AS ttl_forest_area,
            ROUND(SUM(total_area_sqkm)::NUMERIC,2) AS ttl_land_area,
            ROUND((SUM(forest_area_sqkm) / SUM(total_area_sqkm))::NUMERIC * 100, 2) AS pct_forest
        FROM forestation
        WHERE year = 1990 AND country_code != 'WLD'
        GROUP BY 1
    ),
  tbl_2016 AS
      (
          SELECT income_group,
                 COUNT(*) AS COUNT,
                 ROUND(SUM(forest_area_sqkm)::NUMERIC,2) AS ttl_forest_area,
                 ROUND(SUM(total_area_sqkm)::NUMERIC,2) AS ttl_land_area,
                 ROUND((SUM(forest_area_sqkm) / SUM(total_area_sqkm))::NUMERIC * 100, 2) AS pct_forest
          FROM forestation
          WHERE year = 2016 AND country_code != 'WLD'
          GROUP BY 1
      )
SELECT tbl_1990.income_group, tbl_2016.COUNT,
       tbl_1990.ttl_forest_area AS ttl_forest_area_1990,
       tbl_2016.ttl_forest_area AS ttl_forest_area_2016,
       tbl_2016.ttl_forest_area - tbl_1990.ttl_forest_area AS ttl_forest_area_change,
       tbl_1990.pct_forest AS pct_forest_1990,
       tbl_2016.pct_forest AS pct_forest_2016,
       tbl_2016.pct_forest - tbl_1990.pct_forest AS pct_change
FROM tbl_1990
INNER JOIN tbl_2016 ON tbl_1990.income_group = tbl_2016.income_group
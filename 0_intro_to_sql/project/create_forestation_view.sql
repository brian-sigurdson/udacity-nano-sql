-- view for project

CREATE OR replace VIEW forestation AS
SELECT r.country_name,
       r.country_code,
       r.region,
       r.income_group,
       f.year,
       f.forest_area_sqkm,
       f.forest_area_sqkm / 2.59 AS forest_area_sq_mi,
       la.total_area_sq_mi,
       la.total_area_sq_mi * 2.59 AS total_area_sqkm,
       ROUND( (f.forest_area_sqkm / (la.total_area_sq_mi * 2.59) * 100)::NUMERIC, 2) AS percent_forest
FROM regions r
INNER JOIN forest_area f ON r.country_code = f.country_code
INNER JOIN land_area la ON f.country_code = la.country_code AND f.year = la.year
ORDER BY year, country_name
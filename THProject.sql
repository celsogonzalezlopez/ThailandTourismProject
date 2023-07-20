
-- Seeing the most visited provinces overall as well as how the demographic is split between foreign and thai tourists

SELECT
  province,
  round(avg(no_tourist_all)) avgtouristall,
  round(avg(no_tourist_foreign))avgtouristFR,
  round(avg(no_tourist_thai)) avgtouristTH
FROM `thailand-project-389204.Thailand_domestic_tourism.TourismData`
WHERE
  extract(year from date) BETWEEN 2019 AND 2022
GROUP BY
  province
ORDER BY
  avgtouristall DESC

-- Viewing how occupancy rate changes over time for the top 5 overall most visited provinces

SELECT
  EXTRACT(year from date) year,
  province,
  CONCAT(ROUND(AVG(occupancy_rate),2), '%') AS avgOR
FROM `thailand-project-389204.Thailand_domestic_tourism.TourismData`
WHERE
    regexp_contains(province, r'Bangkok|Phetchaburi|Chonburi|Kanchanaburi|Chiang Mai')
    and EXTRACT(year from date) BETWEEN 2019 AND 2022
GROUP BY
  year,
  province

-- Finding which provinces have more foreign than thai tourists

SELECT
  province, 
  round(avg(no_tourist_foreign))avgtouristFR,
  round(avg(no_tourist_thai)) avgtouristTH 
FROM
  `thailand-project-389204.Thailand_domestic_tourism.TourismData` 
WHERE
  extract(year from date) = 2019 
GROUP BY 
  province,
  region
HAVING
  avg(no_tourist_thai) < avg(no_tourist_foreign)
ORDER BY 
  avgtouristFR DESC

-- Finding which provinces have more thai than foreign tourists

SELECT
  province, 
  round(avg(no_tourist_foreign))avgtouristFR,
  round(avg(no_tourist_thai)) avgtouristTH 
FROM
  `thailand-project-389204.Thailand_domestic_tourism.TourismData` 
WHERE 
  extract(year from date) = 2019 
GROUP BY 
  province,
  region
HAVING
  avg(no_tourist_thai) > avg(no_tourist_foreign)
ORDER BY
  avgtouristTH DESC

-- Seeing the peak and bottom months for tourism

SELECT 
  extract(month from date) month,
  round(avg(no_tourist_all)) avgtouristall,
  round(avg(no_tourist_foreign))avgtouristFR,
  round(avg(no_tourist_thai)) avgtouristTH 
FROM `thailand-project-389204.Thailand_domestic_tourism.TourismData`
WHERE 
  extract(year from date) = 2019
GROUP BY 
  month
ORDER BY 
  avgtouristall DESC

-- Create tables for each year from 2019-2022, pull the average occupancy rate for each province

With yr1 AS (
SELECT
  province,
  AVG(occupancy_rate) AS or1
FROM `thailand-project-389204.Thailand_domestic_tourism.TourismData`
WHERE
  date BETWEEN "2019-1-1" AND "2019-12-1"
GROUP BY
  province
), 
yr2 AS (
SELECT
  province,
  AVG(occupancy_rate) AS or2
FROM `thailand-project-389204.Thailand_domestic_tourism.TourismData`
WHERE
  date BETWEEN "2020-1-1" AND "2020-12-1"
GROUP BY
  province
),
yr3 AS (
SELECT
  province,
  AVG(occupancy_rate) AS or3
FROM `thailand-project-389204.Thailand_domestic_tourism.TourismData`
WHERE
  date BETWEEN "2021-1-1" AND "2021-12-1"
GROUP BY
  province
),
yr4 AS (
SELECT
  province,
  AVG(occupancy_rate) AS or4
FROM `thailand-project-389204.Thailand_domestic_tourism.TourismData`
WHERE
  date BETWEEN "2022-1-1" AND "2022-12-1"
GROUP BY
  province
)

-- Combine those tables to see the rate of growth/decline in occupancy rate

SELECT
  yr1.province,
  ((AVG(yr2.or2) - AVG(yr1.or1))/ AVG(yr1.or1))*100 change19to20,
  ((AVG(yr3.or3) - AVG(yr2.or2))/ AVG(yr2.or2))*100 change20to21,
  ((AVG(yr4.or4) - AVG(yr3.or3))/ AVG(yr3.or3))*100 change21to22
FROM yr1
JOIN yr2 USING (province) JOIN yr3 USING (province) JOIN yr4 USING (province)
GROUP BY
  yr1.province

-- Seeing peak tourist entry months and the proportion of spending for each tourist type in 2019

SELECT 
  extract(month from date) month,
  round(avg(no_tourist_all)) avgtouristall,
  round(avg(net_profit_foreign))avgtouristFR,
  round(avg(net_profit_thai)) avgtouristTH 
FROM `thailand-project-389204.Thailand_domestic_tourism.TourismData`
WHERE 
  extract(year from date) = 2019
GROUP BY 
  month
ORDER BY 
  avgtouristall DESC

-- Making cte's for each tourist type's top 5 most visited provinces

with fr as (
SELECT
  extract(year from date) year,
  net_profit_foreign
FROM `thailand-project-389204.Thailand_domestic_tourism.TourismData`
WHERE
  regexp_contains(province, r'Bangkok|Kanchanaburi|Chonburi|PhetchaburiNakhon Ratchasima')
),
th as (
SELECT
  extract(year from date) year,
  net_profit_thai
FROM `thailand-project-389204.Thailand_domestic_tourism.TourismData`
WHERE
  regexp_contains(province, r'Bangkok|Kanchanaburi|Chonburi|Phetchaburi|Nakhon Ratchasima')
)

-- Seeing the annual revenue for each tourist type

SELECT
  year,
  round(sum(fr.net_profit_foreign),2) sumfr,
  round(sum(th.net_profit_thai),2) sumth
FROM fr
JOIN th USING (year)
WHERE
  year between 2019 and 2022
GROUP BY
  year

-- Seeing how high revenue was before COVID

SELECT
  province,
  round(sum(net_profit_all),2) SumRevenue
FROM `thailand-project-389204.Thailand_domestic_tourism.TourismData`
WHERE 
  extract (year from date) = 2019
  AND regexp_contains(province, r'Bangkok|Chonburi|Phuket|Chiang Mai|Nakhon Ratchasima')
GROUP BY
  province
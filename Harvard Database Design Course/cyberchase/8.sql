SELECT COUNT("*") AS "Total Episodes Released in the last 6 years"
FROM "EPISODES"
WHERE "air_date" BETWEEN '2018-01-01' AND '2023-12-31';

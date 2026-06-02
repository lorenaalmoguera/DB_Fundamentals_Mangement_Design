SELECT COUNT("*") AS "Total Episodes Released in first 6 years of Cyberchase"
FROM "EPISODES"
WHERE "air_date" BETWEEN '2002-01-01' AND '2007-12-31';

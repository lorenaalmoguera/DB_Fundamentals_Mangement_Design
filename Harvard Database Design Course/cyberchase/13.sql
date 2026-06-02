SELECT "title"
FROM "EPISODES"
WHERE "title" LIKE 'The%' AND "season" = '3'
GROUP BY "title"
ORDER BY "title";

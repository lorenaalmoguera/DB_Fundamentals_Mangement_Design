SELECT s.city, COUNT(*) AS 'Total_of_Schools_per_District'
FROM SCHOOLS s
WHERE s.type = 'Public School'
GROUP BY s.city
ORDER BY Total_of_Schools_per_District DESC, s.city
LIMIT 10;

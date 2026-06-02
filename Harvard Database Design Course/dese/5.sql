SELECT city, COUNT(*) AS Total
FROM SCHOOLS
WHERE type ='Public School'
GROUP BY city
HAVING Total <= 3
ORDER BY Total DESC, city;

SELECT s.name, d.name
FROM SCHOOLS s
JOIN DISTRICTS d ON d.id = s.district_id
WHERE s.name LIKE 'A%' AND d.name LIKE 'A%';

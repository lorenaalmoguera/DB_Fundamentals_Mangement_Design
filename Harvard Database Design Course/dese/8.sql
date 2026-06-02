SELECT e.pupils, d.name
FROM EXPENDITURES e
INNER JOIN DISTRICTS d ON d.id = e.district_id
ORDER BY e.pupils DESC;

SELECT d.name, e.per_pupil_expenditure
FROM DISTRICTS d
JOIN EXPENDITURES e ON e.district_id = d.id
JOIN SCHOOLS s ON s.district_id = d.id
WHERE d.type = 'Public School District'
GROUP BY d.name
ORDER BY e.per_pupil_expenditure DESC
LIMIT 10;

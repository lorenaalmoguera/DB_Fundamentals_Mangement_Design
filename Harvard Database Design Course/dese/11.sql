SELECT s.name, e.per_pupil_expenditure, g.graduated
FROM SCHOOLS s
INNER JOIN EXPENDITURES e ON e.district_id = s.district_id
INNER JOIN GRADUATION_RATES g ON g.school_id = s.id
ORDER BY e.per_pupil_expenditure DESC, s.name;

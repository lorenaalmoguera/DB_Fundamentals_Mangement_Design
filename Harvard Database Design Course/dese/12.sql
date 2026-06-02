SELECT d.name, e.per_pupil_expenditure, staff.exemplary
FROM DISTRICTS d
INNER JOIN EXPENDITURES e ON e.district_id = d.id
INNER JOIN STAFF_EVALUATIONS staff ON staff.district_id = d.id
WHERE e.per_pupil_expenditure > (
    SELECT AVG(per_pupil_expenditure) FROM EXPENDITURES
) AND staff.exemplary > (
    SELECT AVG(exemplary) FROM STAFF_EVALUATIONS
    ) AND d.type = 'Public School District'
ORDER BY staff.exemplary DESC, e.per_pupil_expenditure DESC;

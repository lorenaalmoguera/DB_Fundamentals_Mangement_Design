SELECT name
FROM SCHOOLS
WHERE district_id IN (
    SELECT id
    FROM DISTRICTS
    WHERE name = 'Cambridge'
);


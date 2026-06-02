CREATE VIEW frequently_reviewed AS
SELECT
listings.id,
listings.property_type,
listings.host_name,
COUNT(reviews.listing_id) AS total
FROM LISTINGS listings
JOIN REVIEWS reviews ON reviews.listing_id = listings.id
GROUP BY listings.id, listings.property_type, listings.host_name
ORDER BY total DESC, listings.property_type ASC, listings.host_name ASC
LIMIT 100;

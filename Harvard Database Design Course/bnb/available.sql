CREATE VIEW available AS
SELECT
listings.id,
listings.property_type,
listings.host_name,
availabilities.date
FROM LISTINGS listings
JOIN AVAILABILITIES availabilities ON availabilities.listing_id = listings.id
WHERE availabilities.available = 'TRUE';

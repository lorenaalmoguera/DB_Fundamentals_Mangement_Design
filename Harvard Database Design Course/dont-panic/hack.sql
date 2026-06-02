
-- Alter password to 'oops'!
UPDATE USERS
SET password = '982c0381c279d139fd221fce974916e7'
WHERE username = 'admin';

-- Delete log
DELETE FROM USER_LOGS
WHERE new_username = 'admin' AND new_password ='982c0381c279d139fd221fce974916e7';

-- Insert fake log
INSERT INTO USER_LOGS (type, old_username, new_username, old_password, new_password) VALUES ('update', 'admin', 'admin', 'e10adc3949ba59abbe56e057f20f883e','44bf025d27eea66336e5c1133c3827f7');

SELECT * FROM USER_LOGS;

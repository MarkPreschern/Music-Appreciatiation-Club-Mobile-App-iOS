USE MacDB;

-- -----------------------------------------------------
-- Inserts default access and role values
-- -----------------------------------------------------
INSERT INTO access (name, description) VALUES
('Developer', 'Admin access and can: Add/Remove any users'),
('Admin', 'Moderator access and can: Add new users with user or moderator access and with any role, can remove users with user and moderator access, can create new roles, can schedule events, can end events'),
('Moderator', 'User access and can: Add new users with user access and member role'),
('User', 'Can use the application as a normal user');

INSERT INTO role (name, description) VALUES
('President', 'President of the club'),
('Lead Mobile Developer', 'Lead developer of the mobile app'),
('Member', 'Member of the club');

-- -----------------------------------------------------
-- Triggers
-- -----------------------------------------------------

-- TODO: recent favorites reset, remove authorization token after 1 hour

DROP PROCEDURE IF EXISTS removeAuthorization;

DELIMITER //

-- -----------------------------------------------------
-- Removes a user's authorization token 1 hour after it was requested, for all user's
-- A user's authorization token can be deemed invalid by the API authorization process by
-- checking if the user's login time > 1 hour before the current time
-- create a job for endEvent that is called when the event datetime is past
-- -----------------------------------------------------


-- TODO: Create job to reset user.authorization token to null after 1 hour after user.login_date


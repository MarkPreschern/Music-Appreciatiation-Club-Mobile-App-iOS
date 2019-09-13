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
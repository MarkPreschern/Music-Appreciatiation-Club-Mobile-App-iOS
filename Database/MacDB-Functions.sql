USE MacDB;

-- -----------------------------------------------------
-- Inserts default access and role values
-- -----------------------------------------------------
INSERT INTO access (name, description) VALUES
('Developer', 'User and Admin access and can: Create new roles, Add new users with any access and role'),
('Admin', 'User access and can: Add new users with user access and member role'),
('User', 'Can use the application as a normal user');

INSERT INTO role (name, description) VALUES
('President', 'President of the club'),
('Lead Mobile Developer', 'Lead developer of the mobile app'),
('Member', 'Member of the club');

-- -----------------------------------------------------
-- Procedures
-- -----------------------------------------------------

-- TODO: validate authorization 

-- -----------------------------------------------------
-- Triggers
-- -----------------------------------------------------

-- TODO: weekly favorites reset, remove authorization token after 1 hour
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

-- Updates database when an event ends
DELIMITER //
CREATE PROCEDURE endEvent()
BEGIN

 -- The event ID
declare ending_event_id INT;

-- Gets the event ID of the recently ended event
SELECT event_id, MAX(end_date)
INTO ending_event_id
FROM event;

-- Temporary table stores the popular picks from this event
DROP TABLE IF EXISTS event_popular_picks;
CREATE TABLE IF NOT EXISTS event_popular_picks (
`pick_id` INT NOT NULL,
`date_picked` DATETIME NOT NULL,
`user_id` INT NOT NULL,
`item_id` VARCHAR(100) NOT NULL,
`event_id` INT NOT NULL);

-- Inserts the top 5 albums and Songs from this event into the event_popular_picks table
INSERT INTO event_popular_picks
SELECT *
FROM 
(
	SELECT pick.*
    FROM pick
    JOIN item on pick.item_id like item.item_id
    WHERE event_id = ending_event_id AND item.is_album = 0
    ORDER BY totalVotes(pick.pick_id) DESC
    LIMIT 5
),
(
	SELECT pick.*
    FROM pick
	JOIN item on pick.item_id like item.item_id
	WHERE event_id = ending_event_id AND item.is_album = 1
    ORDER BY totalVotes(pick.pick_id) DESC
    LIMIT 5
);

-- TODO: Insert event_popular_picks into MacDB.popular table
-- TODO: Delete MacDB.pick data that aren't popular picks
-- TODO: Delete MacDB.item data that aren't popular pick items
-- TODO: Delete all votes
-- TODO: Create a new event


DROP TABLE IF EXISTS event_popular_picks;

END //
DELIMITER ;



-- Gets the total number of votes for a given pick
DELIMITER //
CREATE PROCEDURE totalVotes(input_pick_id INT)
BEGIN

SELECT
(
	SELECT COUNT(vote.vote_id)
	FROM vote 
	JOIN pick on vote.pick_id = pick.pick_id
	WHERE vote.up = 1 and vote.pick_id = input_pick_id
)
-
(
	SELECT COUNT(vote.vote_id)
	FROM vote 
	JOIN pick on vote.pick_id = pick.pick_id
	WHERE vote.up = 0 and vote.pick_id = input_pick_id
);

END //
DELIMITER ;
 
USE MacDB;

-- -----------------------------------------------------
-- Inserts default access and role values
-- -----------------------------------------------------
INSERT INTO access (name, description) VALUES
('Developer', 'Admin access and can: Add/Remove any users'),
('Admin', 'Moderator access and can: Add new users with user or moderator access and with any role, can remove users with user and moderator access, can create new roles and delete existing roles, can schedule events, can end events'),
('Moderator', 'User access and can: Add/Remove users with user access and member role'),
('User', 'Can use the application as a normal user');

INSERT INTO role (name, description) VALUES
('Member', 'Member of the club'),
('President', 'President of the club'),
('Lead Mobile Developer', 'Lead developer of the mobile app');

-- -----------------------------------------------------
-- Functions and Stored Procedures
-- -----------------------------------------------------

-- Creates an event schedule that only triggers 
DROP EVENT IF EXISTS schedule_end_event;
DELIMITER //
CREATE EVENT IF NOT EXISTS schedule_end_event
ON SCHEDULE 
	EVERY 1 DAY
    STARTS timestamp(curdate(), '23:00:00')
DO
BEGIN
	DECLARE eventIsEnding INT; -- the number of events that are ending today
	
    -- gets the number of events ending today
    SELECT count(*)
    INTO eventIsEnding
    FROM event
    WHERE DATE(event.end_date) = curdate();

	-- ends the event if applicable
	IF eventIsEnding > 0 THEN
		CALL endEvent();
    END IF;
END //

-- Updates database when an event ends
DELIMITER //
CREATE PROCEDURE endEvent()
BEGIN

 -- The event ID
declare ending_event_id INT;

-- Gets the event ID of the recently ended event
SELECT event_id
INTO ending_event_id
FROM event
ORDER BY end_date DESC
LIMIT 1;

-- Temporary table stores the popular picks from this event
DROP TABLE IF EXISTS event_popular_picks;
CREATE TABLE IF NOT EXISTS event_popular_picks (
`pick_id` INT NOT NULL,
`date_picked` DATETIME NOT NULL,
`user_id` INT NOT NULL,
`item_id` VARCHAR(100) NOT NULL,
`event_id` INT NOT NULL,
`votes` INT NOT NULL);

-- Inserts the top 5 albums and Songs from this event into the event_popular_picks table
INSERT INTO event_popular_picks
SELECT *
FROM 
(
	SELECT p1.*, totalVotes(p1.pick_id)
    FROM pick as p1
    JOIN item on p1.item_id like item.item_id
    WHERE p1.event_id = ending_event_id AND item.is_album = 0
    ORDER BY totalVotes(p1.pick_id) DESC
    LIMIT 5
) as songs
UNION
(
	SELECT p2.*, totalVotes(p2.pick_id)
	FROM pick as p2
	JOIN item on p2.item_id like item.item_id
	WHERE p2.event_id = ending_event_id AND item.is_album = 1
	ORDER BY totalVotes(p2.pick_id) DESC
	LIMIT 5
);

-- Inserts event_popular_picks into MacDB.popular table
INSERT INTO popular (pick_id, user_id, item_id, event_id, votes)
SELECT epp.pick_id, epp.user_id, epp.item_id, epp.event_id, epp.votes
FROM event_popular_picks epp;

-- Deletes MacDB.pick data that aren't popular picks
DELETE FROM pick
WHERE pick.pick_id NOT IN 
(
	SELECT pick_id
    FROM event_popular_picks
);

-- Deletes MacDB.item data that aren't popular pick items
DELETE FROM item
WHERE item.item_id NOT IN
(
	SELECT item_id
    FROM event_popular_picks
);

-- Deletes all votes
DELETE FROM vote;

-- Creates a new event at 11:00 PM the following week
INSERT INTO event (name, description, start_date, end_date) VALUES
('Weekly Event', 'The Music Appreciation Club\'s weekly event', current_timestamp(), timestamp(date_add(curdate(), INTERVAL 1 WEEK), '23:00:00'));

-- Drops the temporary table
DROP TABLE IF EXISTS event_popular_picks;

END //
DELIMITER ;

-- Gets the total number of votes for a given pick
DELIMITER //
CREATE FUNCTION totalVotes(input_pick_id INT)
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN

DECLARE count int;

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
)
INTO count;

RETURN count;
END //
DELIMITER ;
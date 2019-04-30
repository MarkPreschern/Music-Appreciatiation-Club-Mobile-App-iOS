<?php

$dbHost = "localhost";
$dbUser = "root";
$dbPassword = "";
$dbName = "music_appreciation_club";
$dbConnectionError = "Count not connect to Database";
$dbNullError = "Input is null";

$sqlConnection = new mysqli($dbHost, $dbUser, $dbPassword, $dbName) or die($dbConnectionError);


/***********************************************************************************************************************
 *
 *                                                  QUERIES TO DATABASE
 *
 **********************************************************************************************************************/


//returns the user_id of the given user if their information can be found, or throws an error otherwise
function isValidUserLogin($name_first, $name_last, $nuid)
{
    global $sqlConnection;
    global $dbNullError;
    
    if ($name_first == null || $name_last == null || $nuid == null) {
        die($dbNullError);
    }
    
    $sql = "SELECT *
            FROM user
            WHERE name_first = '$name_first' AND name_last = '$name_last' AND nuid = '$nuid'
            LIMIT 1;";
    $query = $sqlConnection->query($sql);

    if ($query == false || sqlite_num_rows($query) == 0) {
        die("User not found.");
    } else {
        echo $query->fetch_assoc()['user_id'];
    }
}


/***********************************************************************************************************************
 *
 *                                                  INSERTS TO DATABASE
 *
 **********************************************************************************************************************/


//creates a new user and inserts it into the table
function createUser($name_first, $name_last, $nuid, $role_id) {
    global $sqlConnection;
    $sql = "INSERT INTO user (name_first, name_last, nuid, role_id)
            VALUES ('$name_first', '$name_last', '$nuid', '$role_id');";
    if ($sqlConnection->query($sql)) {
        echo "Success";
    } else {
        echo "Failure";
    }
}

//creates a new role and inserts it into the table
function createRole($name, $description) {
    global $sqlConnection;
    $sql = "INSERT INTO role (name, description)
            VALUES ('$name', '$description');";
    if ($sqlConnection->query($sql)) {
        echo "Success";
    } else {
        echo "Failure";
    }
}


//creates a new favorite_weekly and inserts it into the table. There is no way for a user to create a new favorite as
//they can only create one on a weekly basis and therefore in the weekly favorites table.
function createFavoriteWeekly($user_id, $item_id) {
    date_default_timezone_set('America/New_York');
    $date = date('m/d/Y h:i:s', time());

    global $sqlConnection;
    $sql = "INSERT INTO favorite_weekly (date_favorited, user_id, item_id)
            VALUES ('$date', '$user_id', '$item_id');";
    if ($sqlConnection->query($sql)) {
        echo "Success";
    } else {
        echo "Failure";
    }
}


//creates a new vote and inserts it into the table, where the favorite_id is -1 by default since a user shouldn't be
//able to vote on a non-weekly favorite
function createVote($up, $comment, $user_id, $favorite_weekly_id) {
    global $sqlConnection;
    $sql = "INSERT INTO vote (up, comment, user_id, favorite_id, favorite_weekly_id)
            VALUES ('$up', '$comment', '$user_id', -1, '$favorite_weekly_id');";
    if ($sqlConnection->query($sql)) {
        echo "Success";
    } else {
        echo "Failure";
    }
}


//creates a new item and inserts it into the table
function createItem($is_album, $name, $artist) {
    global $sqlConnection;
    $sql = "INSERT INTO item (is_album, name, artist)
            VALUES ('$is_album', '$name', '$artist');";
    if ($sqlConnection->query($sql)) {
        echo "Success";
    } else {
        echo "Failure";
    }
}


/***********************************************************************************************************************
 *
 *                                                  UPDATES TO DATABASE
 *
 **********************************************************************************************************************/




/***********************************************************************************************************************
 *
 *                                                  DELETIONS FROM DATABASE
 *
 **********************************************************************************************************************/


//deletes a user with the given user_id
function deleteSong($user_id) {
    global $sqlConnection;
    $sql = "DELETE FROM user
            WHERE user_id = '$user_id'";
    if ($sqlConnection->query($sql)) {
        echo "Success";
    } else {
        echo "Failure";
    }
}


//deletes a role with the given role_id
function deleteRole($role_id) {
    global $sqlConnection;
    $sql = "DELETE FROM role
            WHERE role_id = '$role_id'";
    if ($sqlConnection->query($sql)) {
        echo "Success";
    } else {
        echo "Failure";
    }
}


//deletes a favorite with the given favorite_id
function deleteFavorite($favorite_id) {
    global $sqlConnection;
    $sql = "DELETE FROM favorite
            WHERE favorite_id = '$favorite_id'";
    if ($sqlConnection->query($sql)) {
        echo "Success";
    } else {
        echo "Failure";
    }
}


//deletes a favorite_weekly with the given favorite_weekly_id
function deleteFavoriteWeekly($favorite_weekly_id) {
    global $sqlConnection;
    $sql = "DELETE FROM favorite_weekly
            WHERE favorite_weekly_id = '$favorite_weekly_id'";
    if ($sqlConnection->query($sql)) {
        echo "Success";
    } else {
        echo "Failure";
    }
}


//deletes a vote with the given vote_id
function deleteVote($vote_id) {
    global $sqlConnection;
    $sql = "DELETE FROM vote
            WHERE vote_id = '$vote_id'";
    if ($sqlConnection->query($sql)) {
        echo "Success";
    } else {
        echo "Failure";
    }
}


//deletes a vote with the given vote_id
function deleteItem($item_id) {
    global $sqlConnection;
    $sql = "DELETE FROM item
            WHERE item_id = '$item_id'";
    if ($sqlConnection->query($sql)) {
        echo "Success";
    } else {
        echo "Failure";
    }
}
<?php


$dbHost = "localhost";
$dbUser = "root";
$dbPassword = "";
$dbName = "music_appreciation_club";
$dbConnectionError = "Count not connect to Database";
$dbNullError = "Input is null";

$sqlConnection = new mysqli($dbHost, $dbUser, $dbPassword, $dbName) or die($dbConnectionError);

//returns true if the username and passwords is contained in the database
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
            LIMIT 1;")
    $query = $sqlConnection->query($sql);

    return sqlite_num_rows($query) != 0;
}

// imports
const MySQL = require('mysql');
const UUID4 = require('uuid4');
const fs = require("file-system");

// Music Appreciation Club API
exports.handler = async (event) => {
    // prints the event
    console.log('\nEvent: ' + JSON.stringify(event, null, 2) + "\n");

    let con;
    // creates database connection, authorizes the request, and executes the specified request respectively
    // response is of the form if successful:
    // {
    //      'statusCode': '200'
    // }
    // response is of the form if an error occurred:
    // {
    //      'statusCode': '<error status>',
    //      'title': '<error general message>',
    //      'description': '<error detailed description>',
    //      'stack race': '<error stack trace>'
    // }
    return await new Promise(function (resolve, reject) {
        // establishes database connection
        try {
            establishDatabaseConnection(function (response1, sqlConnection) {
                if (response1.statusCode === "200") {

                    console.log("Established Database Connection");
                    // MySQL database connection
                    con = sqlConnection;
                    // abbreviated http path without "/" and "api.mac.com"
                    const path = event.path.replace(/\//g, '').replace("api.mac.com", '');

                    // requests authorization to use the api from the user
                    authorizeRequest(event, con, path, function (response2) {
                        if (response2.statusCode === "200") {
                            console.log("Authorized Request");

                            getCurrentEventID(con, function (response3) {
                                if (response3.statusCode === "200") {

                                    let eventID = response3.event_id;
                                    // executes the user request
                                    executeRequest(con, eventID, event, path, function(response4) {
                                        resolve(response4);
                                    });
                                } else {
                                    resolve(response3)
                                }
                            });
                        } else {
                            resolve(response2);
                        }
                    });
                } else {
                    resolve(response1);
                }
            });
        } catch (error) {
            reject(error);
        }
    }).then(data => {
        con.end();
        return jsonFormat(data);
    }).catch(error => {
        con.end();
        return jsonFormat(createErrorMessage("404", "Server-side error", "Unknown exception occurred", error))
    });
};

// creates an instance of the database and makes a connection to it
function establishDatabaseConnection(callbackLocal) {
    // creates mysql connection using environment variables
    /*const con = MySQL.createConnection({
        "host": process.env.host,
        "user": process.env.user,
        "password": process.env.password,
        "database": process.env.database
    });*/

    // for local use
    // creates mysql connection using environment variables
    const json = require('/Users/markpreschern/Documents/env.json');
    const con = MySQL.createConnection({
        host: json.host,
        user: json.user,
        password: json.password,
        database: json.database
    });

    // attempts to connect to the database
    con.connect(function (error) {
        if (error) {
            con.end();
            callbackLocal(createErrorMessage("404", "Connection Error", "Failed to connect to database", error), con);
        } else {
            callbackLocal({
                "statusCode": "200",
            }, con);
        }
    });
}

// verifies that the request is authorized by validating the user's authorization token
function authorizeRequest(event, con, path, callbackLocal) {
    // JSON Data Header: for all methods except postAuthorization
    // {
    //  headers: {
    //      authorization_token: <token>
    //      user_id: <user_id>
    // }
    // }

    // Verify authorization token if not requesting for one
    if (path === "authorization") {
        callbackLocal({
            "statusCode": "200" // requesting authorization token
        });
    } else {
        // constructs the sql statement
        const structure = 'SELECT * '
            + 'FROM user '
            + 'WHERE user.authorization = ? AND user.user_id = ? AND timestampdiff(hour, user.login_date, current_timestamp()) < 1 ';
        const inserts = [event.headers.authorization_token, event.headers.user_id];
        const sql = MySQL.format(structure, inserts);

        // attempts to query the sql statement
        con.query(sql, function (error, results) {
            if (error) {
                callbackLocal(createErrorMessage("404", "Authorization Error", "failed to authorize user due to server-side error", error));
            }

            if (results.length === 0) { // invalid authorization token
                callbackLocal(createErrorMessage("404", "Authorization Error", "failed to authorize user due to invalid authorization credentials", error));
            } else { // valid authorization token
                callbackLocal({
                    "statusCode": "200"
                });
            }
        });
    }
}

// Returns the current event ID
function getCurrentEventID(con, callback) {
    const structure = 'SELECT * '
        + 'FROM event '
        + 'WHERE ? BETWEEN start_date AND end_date '
        + 'ORDER BY end_date DESC '
        + 'LIMIT 1';
    const inserts = [dateTime()];
    const sql = MySQL.format(structure, inserts);

    // attempts to insert the authorization token
    con.query(sql, function (error, results) {
        if (error) {
            callback(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
        } else {
            if (results.length === 0) {
                callback(createErrorMessage("404", "Server-side Error", "Missing Event Data", error));
            } else {
                callback({
                    "statusCode": "200",
                    "event_id": results[0]["event_id"]
                });
            }
        }
    });
}

// executes the provided event request
// HTTP Request Format: http://com.mac.api/requestPath/
// - where 'requestPath' is part of the function call
function executeRequest(con, eventID, event, path, callback) {
    const functionName = event.httpMethod.toLowerCase()
        + path.charAt(0).toUpperCase()
        + path.slice(1);

    console.log("Evaluating: " + functionName);
    eval(functionName)(con, eventID, event, function(response) {
        callback(response);
    });
}


/*
 ****************** GET METHODS ***************
 */

// gets the user's access
function getAccess(con, eventID, event, callback) {
    const structure = 'SELECT access.* '
        + 'FROM access '
        + 'JOIN user ON access.access_id = user.access_id '
        + 'WHERE user_id = ? ';
    const inserts = [event.headers.user_id];
    const sql = MySQL.format(structure, inserts);

    con.query(sql, function (error, results) {
        if (error) {
            callback(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
        } else {
            callback({
                statusCode: "200",
                message: "Successfully retrieved user's access",
                items: results
            });
        }
    });
}

// gets the user's role
function getRole(con, eventID, event, callback) {
    const structure = 'SELECT role.* '
        + 'FROM role '
        + 'JOIN user ON role.role_id = user.role_id '
        + 'WHERE user_id = ? ';
    const inserts = [event.headers.user_id];
    const sql = MySQL.format(structure, inserts);

    con.query(sql, function (error, results) {
        if (error) {
            callback(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
        } else {
            callback({
                statusCode: "200",
                message: "Successfully retrieved user's role",
                items: results
            });
        }
    });
}

// gets the user's image
function getImage(con, eventID, event, callback) {
    const structure = 'SELECT image.* '
        + 'FROM image '
        + 'JOIN user ON image.image_id = user.image_id '
        + 'WHERE user_id = ? ';
    const inserts = [event.headers.user_id];
    const sql = MySQL.format(structure, inserts);

    con.query(sql, function (error, results) {
        if (error) {
            callback(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
        } else {
            callback({
                statusCode: "200",
                message: "Successfully retrieved user's image",
                items: results
            })
        }
    });
}

// gets the user's recent song picks
function getUserSongPicks(con, eventID, event, callback) {
    const structure = 'SELECT item.item_id, item.is_album, item.item_name, item.item_artist, item.item_image_url, item.item_preview_url, pick.pick_id, user.user_id, user.name '
        + 'FROM item '
        + 'JOIN pick ON item.item_id = pick.item_id '
        + 'JOIN user ON pick.user_id = user.user_id '
        + 'WHERE is_album = 0 and pick.user_id = ? and pick.event_id = ? ';
    const inserts = [event.headers.user_id, eventID];
    const sql = MySQL.format(structure, inserts);

    con.query(sql, function (error, results) {
        if (error) {
            callback(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
        } else {
            parsePicksVoteData(false, con, results, function(result) {
                callback(result);
            });
        }
    });
}

// gets the user's recent album picks
function getUserAlbumPicks(con, eventID, event, callback) {
    const structure = 'SELECT item.item_id, item.is_album, item.item_name, item.item_artist, item.item_image_url, item.item_preview_url, pick.pick_id, user.user_id, user.name '
        + 'FROM item '
        + 'JOIN pick ON item.item_id = pick.item_id '
        + 'JOIN user ON pick.user_id = user.user_id '
        + 'WHERE is_album = 1 and pick.user_id = ? and pick.event_id = ? ';
    const inserts = [event.headers.user_id, eventID];
    const sql = MySQL.format(structure, inserts);

    con.query(sql, function (error, results) {
        if (error) {
            callback(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
        } else {
            parsePicksVoteData(true, con, results, function(result) {
                callback(result);
            });
        }
    });
}

// gets recent song picks
function getClubSongPicks(con, eventID, event, callback) {
    const structure = 'SELECT item.item_id, item.is_album, item.item_name, item.item_artist, item.item_image_url, item.item_preview_url, pick.pick_id, user.user_id, user.name '
        + 'FROM item '
        + 'JOIN pick ON item.item_id = pick.item_id '
        + 'JOIN user ON pick.user_id = user.user_id '
        + 'WHERE is_album = 0 and pick.event_id = ? ';
    const inserts = [eventID];
    const sql = MySQL.format(structure, inserts);

    con.query(sql, function (error, results) {
        if (error) {
            callback(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
        } else {
            parsePicksVoteData(false, con, results, function(result) {
                callback(result);
            });
        }
    });
}

// gets recent song picks
function getClubAlbumPicks(con, eventID, event, callback) {
    const structure = 'SELECT item.item_id, item.is_album, item.item_name, item.item_artist, item.item_image_url, item.item_preview_url, pick.pick_id, user.user_id, user.name '
        + 'FROM item '
        + 'JOIN pick ON item.item_id = pick.item_id '
        + 'JOIN user ON pick.user_id = user.user_id '
        + 'WHERE is_album = 1 and pick.event_id = ? ';
    const inserts = [eventID];
    const sql = MySQL.format(structure, inserts);

    con.query(sql, function (error, results) {
        if (error) {
            callback(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
        } else {
            parsePicksVoteData(true, con, results, function(result) {
                callback(result);
            });
        }
    });
}

// gets the user's popular song and album picks
function getUserPopularPicks(con, eventID, event, callback) {
    const structure = 'SELECT item.item_id, item.is_album, item.item_name, item.item_artist, item.item_image_url, item.item_preview_url, popular.popular_id, popular.votes '
        + 'FROM item '
        + 'JOIN popular ON item.item_id = popular.item_id '
        + 'JOIN user ON popular.user_id = user.user_id '
        + 'WHERE popular.user_id = ? and popular.event_id = ? '
        + 'ORDER BY popular.votes DESC';
    const inserts = [event.headers["member_id"], eventID];
    const sql = MySQL.format(structure, inserts);

    con.query(sql, function (error, results) {
        if (error) {
            callback(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
        } else {
            callback({
                statusCode: "200",
                message: "Successfully retrieved user's popular picks",
                popular_picks: results
            });
        }
    });
}

// gets all user's and their necessary user information except for the user who sent the request
function getUsers(con, eventID, event, callback) {
    const structure = 'SELECT user.user_id, user.name AS user_name, role.name AS role_name, role.description, image.image_data '
        + 'FROM user '
        + 'JOIN role ON user.role_id = role.role_id '
        + 'LEFT JOIN image ON user.image_id = image.image_id '
        + 'WHERE user.user_id != ? '
        + 'ORDER BY user.name ASC ';
    const inserts = [event.headers.user_id];
    const sql = MySQL.format(structure, inserts);

    con.query(sql, function (error, results) {
        if (error) {
            callback(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
        } else {
            callback({
                statusCode: "200",
                message: "Successfully retrieved users",
                users: results
            });
        }
    });
}


/*
 ****************** POST METHODS ***************
 */

// validates that the user with the specified name and nuid exists, and generates an
// authorization token for the user if so
function postAuthorization(con, eventID, event, callback) {

    // validates the user and updates their validation token
    callback(new Promise(function(resolve, reject) {
        try {
            validateUser(function (response1) {
                if (response1.statusCode === "200") {
                    insertAuthorizationToken(response1.user, function (response2) {
                        resolve(response2);
                    });
                } else {
                    resolve(response1)
                }
            });
        } catch (error) {
            reject(error);
        }
    }).then(data => {
        return data;
    }).catch(error => {
        return createErrorMessage("404", "Server-side Error", "Failed to execute request due to unknown exception", error);
    }));

    // sql query to validate that the user exists
    function validateUser(callbackLocal) {
        const structure1 = 'SELECT * '
            + 'FROM user '
            + 'WHERE name = ? AND nuid LIKE ?';
        const inserts1 = [event.headers.name, event.headers.nuid];
        const sql1 = MySQL.format(structure1, inserts1);

        // gets the user's id if they exist
        con.query(sql1, function (error, results) {
            if (error) {
                return callbackLocal(createErrorMessage("404", "User Validation Error", "Failed to validate user due to server-side error", error));
            } else if (results.length === 0) { // invalid login credentials
                return callbackLocal(createErrorMessage("404", "User Validation Error", "failed to validate user due to invalid login credentials", error));
            } else { // valid login credentials
                return callbackLocal({
                    "statusCode": "200",
                    "message": "Successfully validated user",
                    "user": results[0]
                });
            }
        });
    }

    // sql query to generate an authorization token for the user
    function insertAuthorizationToken(user, callbackLocal) {
        const uuid = UUID4();
        const structure2 = 'UPDATE user '
            + 'SET authorization = ? , login_date = ? '
            + 'WHERE user_id = ?';
        const inserts2 = [uuid, dateTime(), user["user_id"]];
        const sql2 = MySQL.format(structure2, inserts2);

        // attempts to insert the authorization token
        con.query(sql2, function (error) {
            if (error) {
                callbackLocal(createErrorMessage("404", "Authorization Error", "failed to update authorization token due to server-side error", error));
            } else {
                callbackLocal({
                    "statusCode": "200",
                    "message": "Successfully created authorization token",
                    "user": {
                        "user_id": user["user_id"],
                        "name": user["name"],
                        "nuid": user["nuid"],
                        "authorization": uuid,
                        "role_id": user["role_id"],
                        "access_id": user["access_id"]
                    }
                });
            }
        });
    }
}

// creates the item associated with this pick, and the pick with the newly created item
function postUser(con, eventID, event, callback) {

    callback(getAccessPromise(con, event).then(data => {
        if (data.statusCode === "200") {
            if ( // verifying correct access rights for action
                (data.access === "Moderator" && event.headers["access"] === "User" && event.headers["role"] === "Member") ||
                (data.access === "Admin" && (event.headers["access"] === "User" || event.headers["access"] === "Moderator")) ||
                data.access === "Developer") {
                return insertUser();
            } else {
                return createErrorMessage("404", "Invalid Access", "Failed to query requested data due to invalid access", null);
            }
        } else {
            return data;
        }
    }).catch(error => {
        return error;
    }));

    // inserts the user
    function insertUser() {
        return new Promise(function (resolve, reject) {
            const structure = 'INSERT INTO user (name, nuid, login_date, access_id, role_id) '
                + 'VALUES ( ? , ? , ? , ? , ? ) ';
            const inserts = [event.headers["user_name"], event.headers["user_nuid"], dateTime(), event.headers["access_id"], event.headers["role_id"]];
            const sql = MySQL.format(structure, inserts);

            // attempts to insert the authorization token
            con.query(sql, function (error, results) {
                if (error) {
                    reject(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
                } else {
                    resolve({
                        "statusCode": "200",
                        "message": "Success added user"
                    });
                }
            });
        })
    }
}

// creates the item associated with this pick, and the pick with the newly created item
function postPick(con, eventID, event, callback) {

    callback(picksCount().then(function() {
        return addItem();
    }).then(function() {
        return addPick();
    }).then(function() {
        return getPickID();
    }).catch(error => {
        return error;
    }));

    // Returns the current amount of user picks for this item type
    function picksCount() {
        return new Promise(function (resolve, reject) {
            const structure = 'SELECT count(*) '
                + 'FROM pick '
                + 'JOIN item ON pick.item_id = item.item_id '
                + 'WHERE item.is_album = ? AND pick.user_id = ? ';
            const inserts = [event.headers["item_is_album"], event.headers["user_id"]];
            const sql = MySQL.format(structure, inserts);

            // attempts to insert the authorization token
            con.query(sql, function (error, results) {
                if (error) {
                    reject(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
                } else {
                    let count = results[0]["count(*)"];
                    if (event.headers["item_is_album"] === "1" && count > 3) {
                        reject(createErrorMessage("404", "Insertion Error", "Failed to insert a new album pick as you have exceeded 3 album picks ", error));
                    } else if (event.headers["item_is_album"] === "0" && count > 5) {
                        reject(createErrorMessage("404", "Insertion Error", "Failed to insert a new song pick as you have exceeded 5 song picks", error));
                    } else {
                        resolve()
                    }
                }
            });
        })
    }

    // Add's an item with the provided item data if the item id is unique
    function addItem() {
        return new Promise(function (resolve, reject) {
            const structure = 'INSERT INTO item (item_id, is_album, item_name, item_artist, item_image_url, item_preview_url) '
                + 'VALUES ( ? , ? , ? , ? , ? , ? ) ';
            const inserts = [event.headers["item_id"], event.headers["item_is_album"], event.headers["item_name"], event.headers["item_artist"], event.headers["item_image_url"], event.headers["item_preview_url"]];
            const sql = MySQL.format(structure, inserts);

            // attempts to insert the authorization token
            con.query(sql, function (error) {
                if (error) {
                    if (error["code"] === "ER_DUP_ENTRY") { // don't want to allow multiple users to pick the same item
                        reject(createErrorMessage("404", "Duplicate Entry", "This " + (event.headers["item_is_album"] === "1" ? "album" : "song") + " has already been chosen for this event or was popular in a previous event", error))
                    } else {
                        reject(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
                    }
                } else {
                    resolve();
                }
            });
        })
    }

    // Returns the current event ID
    function getEventID() {
        return new Promise(function (resolve, reject) {
            const structure = 'SELECT * '
                + 'FROM event '
                + 'WHERE ? BETWEEN start_date AND end_date '
                + 'ORDER BY end_date DESC '
                + 'LIMIT 1';
            const inserts = [dateTime()];
            const sql = MySQL.format(structure, inserts);

            // attempts to insert the authorization token
            con.query(sql, function (error, results) {
                if (error) {
                    reject(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
                } else {
                    if (results.length === 0) {
                        reject(createErrorMessage("404", "Server-side Error", "Missing Event Data", error));
                    } else {
                        resolve(results[0]["event_id"]);
                    }
                }
            });
        })
    }

    // adds the pick
    function addPick() {
        return new Promise(function (resolve, reject) {
            const structure = 'INSERT INTO pick (date_picked, user_id, item_id, event_id) '
                + 'VALUES ( ? , ? , ? , ? ) ';
            const inserts = [dateTime(), event.headers["user_id"], event.headers["item_id"], eventID];
            const sql = MySQL.format(structure, inserts);

            // attempts to insert the authorization token
            con.query(sql, function (error) {
                if (error) {
                    reject(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
                } else {
                    resolve();
                }
            });
        })
    }

    // gets the pick id using it's item_id since item_id has a unique constraint
    function getPickID() {
        return new Promise(function (resolve, reject) {
            const structure = 'SELECT pick_id '
                + 'FROM pick '
                + 'WHERE pick.item_id = ? ';
            const inserts = [event.headers["item_id"]];
            const sql = MySQL.format(structure, inserts);

            // attempts to insert the authorization token
            con.query(sql, function (error, results) {
                if (error) {
                    reject(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
                } else {
                    if (results.length === 0) {
                        reject(createErrorMessage("404", "Server-side Error", "Missing pick data", error));
                    } else if (results.length > 1) {
                        reject(createErrorMessage("404", "Server-side Error", "Invalid pick data, duplicate items", error));
                    } else {
                        resolve({
                            "statusCode": "200",
                            "message": "Added " + event.headers["item_name"] + " by " + event.headers["item_artist"] + " to picks",
                            "pick_id": results[0]
                        });
                    }
                }
            });
        })
    }
}

// creates the vote if the user isn't voting for their own pick
function postVote(con, eventID, event, callback) {

    callback(ownPick().then(function() {
        return duplicatePick();
    }).then(function() {
        return addVote()
    }).then(function() {
        return getVoteID();
    }).catch(error => {
        return error;
    }));

    // determines if the user voted for their own pick
    function ownPick() {
        return new Promise(async function (resolve, reject) {
            const structure = 'SELECT * '
                + 'FROM pick '
                + 'WHERE pick.pick_id = ? AND pick.user_id = ?';
            const inserts = [event.headers["pick_id"], event.headers["user_id"]];
            const sql = MySQL.format(structure, inserts);

            await con.query(sql, function (error, results) {
                if (error) {
                    reject(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
                } else {
                    if (results.length > 0) {
                        reject(createErrorMessage("404", "Vote Error", "You can't vote for your own " + (event.headers["item_is_album"] === "1" ? "album" : "song") + "!", error))
                    } else {
                        resolve();
                    }
                }
            });
        });
    }

    // determines if the user voted for the same pick more than once
    function duplicatePick() {
        return new Promise(async function (resolve, reject) {
            const structure = 'SELECT * '
                + 'FROM vote '
                + 'WHERE vote.pick_id = ? AND vote.user_id = ?';
            const inserts = [event.headers["pick_id"], event.headers["user_id"]];
            const sql = MySQL.format(structure, inserts);

            await con.query(sql, function (error, results) {
                if (error) {
                    reject(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
                } else {
                    if (results.length > 0) {
                        reject(createErrorMessage("404", "Vote Error", "You can't vote for this "
                            + (event.headers["item_is_album"] === "1" ? "album" : "song") + " more than once.", error))
                    } else {
                        resolve();
                    }
                }
            });
        });
    }

    // adds the vote from this user to this pick
    function addVote() {
        return new Promise(async function (resolve, reject) {
            const structure = 'INSERT INTO vote (up, comment, user_id, pick_id) '
                + 'VALUES ( ? , ? , ? , ? )';
            const inserts = [event.headers["up"], event.headers["comment"], event.headers["user_id"], event.headers["pick_id"]];
            const sql = MySQL.format(structure, inserts);

            await con.query(sql, function (error) {
                if (error) {
                    reject(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
                } else {
                    resolve();
                }
            });
        });
    }

    // gets the vote id using it's user_id and pick_id as the two form a unique constraint
    function getVoteID() {
        return new Promise(async function (resolve, reject) {
            const structure = 'SELECT vote_id '
                + 'FROM vote '
                + 'WHERE vote.user_id = ? AND vote.pick_id = ?';
            const inserts = [event.headers["user_id"], event.headers["pick_id"]];
            const sql = MySQL.format(structure, inserts);

            await con.query(sql, function (error, results) {
                if (error) {
                    reject(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
                } else {
                    if (results.length === 0) {
                        reject(createErrorMessage("404", "Server-side Error", "Missing vote data", error));
                    } else if (results.length > 1) {
                        reject(createErrorMessage("404", "Server-side Error", "Invalid vote data, duplicate items", error));
                    } else {
                        resolve({
                            "statusCode": "200",
                            "message": "Successfully voted",
                            "vote_id": results[0].vote_id
                        });
                    }
                }
            });
        })
    }
}

// deletes the role if user's access is high enough
function postRole(con, eventID, event, callback) {
    callback(getAccessPromise(con, event).then(data => {
        if (data.statusCode === "200") {
            if (data.access === "Admin" || data.access === "Developer") {
                return postRole();
            } else {
                return createErrorMessage("404", "Invalid Access", "Failed to query requested data due to invalid access", null);
            }
        } else {
            return data;
        }
    }).catch(error => {
        return error;
    }));

    // delete's the user's pick
    function postRole() {
        return new Promise(async function (resolve, reject) {
            const structure = 'INSERT INTO role (name, description) '
                + 'VALUES ( ? , ? ) ';
            const inserts = [event.headers["role_name"], event.headers["role_description"]];
            const sql = MySQL.format(structure, inserts);

            await con.query(sql, function (error) {
                if (error) {
                    reject(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
                } else {
                    resolve({
                        "statusCode": "200",
                        "message": "Successfully created role"
                    });
                }
            });
        });
    }
}

// post the user's image
function postImage(con, eventID, event, callback) {

    let image = base64_encode('image_data.jpg');
    callback(createImage(image).then(function() {
        return getImageID(image);
    }).then(imageID => {
        return setUserImageID()
    }).catch(error => {
        return error;
    }));

    // adds the image data
    function createImage(image) {
        return new Promise(async function (resolve, reject) {
            const structure = 'INSERT INTO image (image_data) '
                + 'VALUES ( ? )';
            const inserts = [image];
            const sql = MySQL.format(structure, inserts);

            await con.query(sql, function (error) {
                if (error) {
                    reject(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
                } else {
                    resolve();
                }
            });
        });
    }

    // gets the image ID of this image data
    function getImageID() {
        return new Promise(async function (resolve, reject) {
            const structure = 'SELECT image_id '
                + 'FROM image '
                + 'WHERE image.image_data = ?';
            const inserts = [image];
            const sql = MySQL.format(structure, inserts);

            await con.query(sql, function (error, results) {
                if (error) {
                    reject(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
                } else {
                    if (results.length === 0) {
                        reject(createErrorMessage("404", "Server-side Error", "Missing image data", error));
                    } else if (results.length > 1) {
                        reject(createErrorMessage("404", "Server-side Error", "Invalid image data, duplicate items", error));
                    } else {
                        resolve(results[0]["image_id"]);
                    }
                }
            });
        })
    }

    // sets the user's imageID to this image
    function setUserImageID(imageID) {
        return new Promise(async function (resolve, reject) {
            const structure = 'UPDATE user '
                + 'SET user.image_id = ? '
                + 'WHERE user.user_id = ? ';
            const inserts = [imageID, event.headers.user_id];
            const sql = MySQL.format(structure, inserts);

            await con.query(sql, function (error) {
                if (error) {
                    reject(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
                } else {
                    resolve();
                }
            });
        });
    }
}

/*
 ****************** DELETE METHODS (Type is POST) ***************
 */

// deletes the pick if it's the user's pick and the pick's item
function postDeletePick(con, eventID, event, callback) {

    callback(deleteVotes().then(function() {
        return deletePick();
    }).then(function () {
        return deleteItem();
    }).catch(error => {
        return error;
    }));

    // delete's the user's pick's votes
    function deleteVotes() {
        return new Promise(async function (resolve, reject) {
            const structure = 'DELETE FROM vote '
                + 'WHERE vote.pick_id = ? ';
            const inserts = [event.headers["pick_id"]];
            const sql = MySQL.format(structure, inserts);

            await con.query(sql, function (error) {
                if (error) {
                    reject(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
                } else {
                    resolve();
                }
            });
        });
    }

    // delete's the user's pick
    function deletePick() {
        return new Promise(async function (resolve, reject) {
            const structure = 'DELETE FROM pick '
                + 'WHERE pick.pick_id = ? AND pick.user_id = ? ';
            const inserts = [event.headers["pick_id"], event.headers["user_id"]];
            const sql = MySQL.format(structure, inserts);

            await con.query(sql, function (error) {
                if (error) {
                    reject(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
                } else {
                    resolve();
                }
            });
        });
    }

    // delete's the user's pick's item
    function deleteItem() {
        return new Promise(async function (resolve, reject) {
            const structure = 'DELETE FROM item '
                + 'WHERE item.item_id = ? ';
            const inserts = [event.headers["item_id"]];
            const sql = MySQL.format(structure, inserts);

            await con.query(sql, function (error) {
                if (error) {
                    reject(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
                } else {
                    resolve({
                        "statusCode": "200",
                        "message": "Successfully deleted pick"
                    });
                }
            });
        });
    }
}

// deletes the vote if it's the user's vote
function postDeleteVote(con, eventID, event, callback) {
    const structure = 'DELETE FROM vote '
        + 'WHERE vote.vote_id = ? AND vote.user_id = ? ';
    const inserts = [event.headers["vote_id"], event.headers["user_id"]];
    const sql = MySQL.format(structure, inserts);

    con.query(sql, function (error) {
        if (error) {
            callback(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
        } else {
            callback({
                "statusCode": "200",
                "message": "Successfully deleted vote"
            });
        }
    });
}

// deletes the role if user's access is high enough
function postDeleteRole(con, eventID, event, callback) {
    callback(getAccessPromise(con, event).then(data => {
        if (data.statusCode === "200") {
            if (data.access === "Admin" || data.access === "Developer") {
                return deleteRole();
            } else {
                return createErrorMessage("404", "Invalid Access", "Failed to query requested data due to invalid access", null);
            }
        } else {
            return data;
        }
    }).catch(error => {
        return error;
    }));

    // delete's the user's pick
    function deleteRole() {
        return new Promise(async function (resolve, reject) {
            const structure = 'DELETE FROM role '
                + 'WHERE role.role_id = ? ';
            const inserts = [event.headers["role_id"]];
            const sql = MySQL.format(structure, inserts);

            await con.query(sql, function (error) {
                if (error) {
                    reject(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
                } else {
                    resolve({
                        "statusCode": "200",
                        "message": "Successfully deleted role"
                    });
                }
            });
        });
    }
}


/*
 ****************** HELPER METHODS ***************
 */

// creates an error message
function createErrorMessage(statusCode, title, description, error) {
    return {
        "statusCode": statusCode,
        "title": title,
        "description": description,
        "stackTrace": error
    }
}

// json/application return format
function jsonFormat(body) {
    return {
        "body": JSON.stringify(body),
        "headers": {'Content-Type': 'application/json'}
    };
}

// gets a sql formatted datetime of now
function dateTime() {
    return new Date().toISOString().slice(0, 19).replace('T', ' ');
}

// function to encode file data to base64 encoded string
function base64_encode(file) {
    // read binary data
    let bitmap = fs.readFileSync(file);
    // convert binary data to base64 encoded string
    return new bitmap.toString('base64');
}

// parses a list of picks data for their respective votes
function parsePicksVoteData(is_album, con, results, callback) {
    if (results.length === 0) {
        callback({
            "statusCode": "200",
            "message": "Successfully retrieved " + (is_album === true ? "album" : "song") + " picks",
            "items": []
        });
    } else {
        let promises = results.map(async item => {
            item["votes"] = await getPickVotes(item["pick_id"], con);
        });
        callback(Promise.all(promises).then(function () {
            return {
                "statusCode": "200",
                "message": "Successfully retrieved " + (is_album === true ? "album" : "song") + " picks",
                "items": results
            };
        }).catch(error => {
            return error;
        }));
    }
}

// Gets all votes of a pick
function getPickVotes(pick_id, con) {

    // gets all up votes for this item
    let getUpVotes = new Promise(async function(resolve, reject) {
        const structure = 'SELECT vote.vote_id, vote.up, vote.comment, vote.user_id, vote.pick_id '
            + 'FROM vote '
            + 'JOIN pick on vote.pick_id = pick.pick_id  '
            + 'WHERE vote.up = 1 and vote.pick_id = ?';
        const inserts = [pick_id];
        const sql = MySQL.format(structure, inserts);

        await con.query(sql, function (error, results) {
            if (error) {
                reject(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
            } else {
                resolve({
                    "votesCount": results.length,
                    "votesData": results
                });
            }
        });
    });

    // gets all down votes for this item
    let getDownVotes = new Promise(async function (resolve, reject) {
        const structure = 'SELECT vote.vote_id, vote.up, vote.comment, vote.user_id, vote.pick_id '
            + 'FROM vote '
            + 'JOIN pick on vote.pick_id = pick.pick_id '
            + 'WHERE vote.up = 0 and vote.pick_id = ?';
        const inserts = [pick_id];
        const sql = MySQL.format(structure, inserts);

        await con.query(sql, function (error, results) {
            if (error) {
                reject(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
            } else {
                resolve({
                    "votesCount": results.length,
                    "votesData": results
                });
            }
        });
    });

    return Promise.all([getUpVotes, getDownVotes]).then(values => {
        return {
            "totalVotes": values[0]["votesCount"] - values[1]["votesCount"],
            "upVoteData": values[0],
            "downVoteData": values[1]
        };
    }).catch(error => {
        return error;
    });
}

// delete's the user's pick's item
function getAccessPromise(con, event) {
    return new Promise(async function (resolve, reject) {
        const structure = 'SELECT access.name '
            + 'FROM access '
            + 'JOIN user ON user.access_id = access.access_id '
            + 'WHERE user.user_id = ? ';
        const inserts = [event.headers["user_id"]];
        const sql = MySQL.format(structure, inserts);

        await con.query(sql, function (error, results) {
            if (error) {
                reject(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
            } else {
                if (results.length === 0) {
                    reject(createErrorMessage("404", "Access Error", "Insufficient Access to perform action", error));
                } else if (results.length > 1) {
                    reject(createErrorMessage("404", "Server-side Error", "Invalid access data, duplicate access", error));
                } else {
                    resolve({
                        "statusCode": "200",
                        "access": results[0]["name"]
                    });
                }
            }
        });
    });
}
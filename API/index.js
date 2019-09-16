// imports
const MySQL = require('mysql');
const UUID4 = require('uuid4');

// Music Appreciation Club API
exports.handler = async (event) => {
    // prints the event
    console.log('\nEvent: ' + JSON.stringify(event, null, 2) + "\n");

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
                    const con = sqlConnection;
                    // abbreviated http path without "/" and "api.mac.com"
                    const path = event.path.replace(/\//g, '').replace("api.mac.com", '');

                    // requests authorization to use the api from the user
                    authorizeRequest(event, con, path, function (response2) {
                        if (response2.statusCode === "200") {
                            console.log("Authorized Request");

                            // executes the user request
                            executeRequest(con, event, path, function(response3) {
                                resolve(response3);
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
        return jsonFormat(data.statusCode, data);
    }).catch(error => {
        return jsonFormat(404, createErrorMessage("404", "Server-side error", "Unknown exception occurred", error))
    });
};

// creates an instance of the database and makes a connection to it
function establishDatabaseConnection(callbackLocal) {
    // prints the event input

    //for remote use

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
            return callbackLocal(createErrorMessage("404", "Connection Error", "Failed to connect to database", error), con);
        } else {
            return callbackLocal({
                "statusCode": "200",
            }, con);
        }
    });
};

// verifies that the request is authorized by validating the user's authorization token
function authorizeRequest(event, con, path, callbackLocal) {
    // JSON Data Header: for all methods except postAuthorization
    // {
    //  headers: {
    //      authorization: <token>
    //      user_id: <user_id>
    // }
    // }

    // Verify authorization token if not requesting for one
    if (path === "authorization") {
        return callbackLocal({
            "statusCode": "200" // requesting authorization token
        });
    } else {
        // constructs the sql statement
        const structure = 'SELECT * '
            + 'FROM user '
            + 'WHERE authorization = ? and user_id = ?';
        const inserts = [event.headers.authorization, event.headers.user_id];
        const sql = MySQL.format(structure, inserts);

        // attempts to query the sql statement
        con.query(sql, function (error, results) {
            if (error) {
                return callbackLocal(createErrorMessage("404", "Authorization Error", "failed to authorize user due to server-side error", error));
            }

            if (results.length === 0) { // invalid authorization token
                return callbackLocal(createErrorMessage("404", "Authorization Error", "failed to authorize user due to invalid authorization credentials", error));
            } else { // valid authorization token
                return callbackLocal({
                    "statusCode": "200"
                });
            }
        });
    }
}

// executes the provided event request
// HTTP Request Format: http://com.mac.api/requestPath/
// - where 'requestPath' is part of the function call
function executeRequest(con, event, path, callback) {
    const functionName = event.httpMethod.toLowerCase()
        + path.charAt(0).toUpperCase()
        + path.slice(1);

    console.log("Evaluating: " + functionName);
    eval(functionName)(con, event, function(response) {
        callback(response);
    });
}


/*
 ****************** GET METHODS ***************
 */

// gets the user's access
function getAccess(con, event, callback) {
    const structure = 'SELECT * '
        + 'FROM access '
        + 'JOIN user on (access_id) '
        + 'WHERE user_id = ?';
    const inserts = [event.headers.user_id];
    const sql = MySQL.format(structure, inserts);

    con.query(sql, function (error, results) {
        if (error) {
            callback(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
        } else {
            callback({
                statusCode: "200",
                message: "Successfully retrieved user's access",
                songs: JSON.stringify(results)
            });
        }
    });
}

// gets the user's recent song picks
function getUserSongPicks(con, event, callback) {
    const structure = 'SELECT item.item_id, item.is_album, item.item_name, item.item_artist, item.item_spotify_id, pick.pick_id '
        + 'FROM item '
        + 'JOIN pick on item.item_id = pick.item_id '
        + 'WHERE is_album = 0 and pick.user_id = ? ';
    const inserts = [event.headers.user_id];
    const sql = MySQL.format(structure, inserts);

    con.query(sql, function (error, results) {
        if (error) {
            callback(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
        } else {
            if (results.length === 0) {
                callback({
                    statusCode: "200",
                    message: "Successfully retrieved recent album picks",
                    songs: JSON.stringify(results)
                });
            } else {
                for (let i = 0; i < results.length; i++) {
                    let pick = results[i];
                    getPickVotes(pick["pick_id"], con, function (response) {
                        results[pick].add({
                            "votes": response
                        });
                    });

                    if (i === results.length - 1) {
                        callback({
                            statusCode: "200",
                            message: "Successfully retrieved recent user song picks",
                            songs: JSON.stringify(results)
                        });
                    }
                }
            }
        }
    });
}

// gets the user's recent album picks
function getUserAlbumPicks(con, event, callback) {
    const structure = 'SELECT item.item_id, item.is_album, item.item_name, item.item_artist, item.item_spotify_id, pick.pick_id '
        + 'FROM item '
        + 'JOIN pick on (item_id)'
        + 'WHERE is_album = 1 and pick.user_id = ? ';
    const inserts = [event.headers.user_id];
    const sql = MySQL.format(structure, inserts);

    con.query(sql, function (error, results) {
        if (error) {
            callback(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
        } else {
            if (results.length === 0) {
                callback({
                    statusCode: "200",
                    message: "Successfully retrieved recent album picks",
                    songs: JSON.stringify(results)
                });
            } else {
                for (let i = 0; i < results.length; i++) {
                    let pick = results[i];
                    getPickVotes(pick["pick_id"], con, function (response) {
                        results[pick].add({
                            "votes": response
                        });
                    });

                    if (i === results.length - 1) {
                        callback({
                            statusCode: "200",
                            message: "Successfully retrieved recent user album picks",
                            songs: JSON.stringify(results)
                        });
                    }
                }
            }
        }
    });
}

// gets recent song picks
function getClubSongPicks(con, event, callback) {
    const sql = 'SELECT item.item_id, item.is_album, item.item_name, item.item_artist, item.item_spotify_id, pick.pick_id '
        + 'FROM item '
        + 'JOIN pick on (item_id)'
        + 'WHERE is_album = 0';

    con.query(sql, function (error, results) {
        if (error) {
            callback(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
        } else {
            if (results.length === 0) {
                callback({
                    statusCode: "200",
                    message: "Successfully retrieved recent album picks",
                    songs: JSON.stringify(results)
                });
            } else {
                for (let i = 0; i < results.length; i++) {
                    let pick = results[i];
                    getPickVotes(pick["pick_id"], con, function (response) {
                        results[pick].add({
                            "votes": response
                        });
                    });


                    if (i === results.length - 1) {
                        callback({
                            statusCode: "200",
                            message: "Successfully retrieved recent song picks",
                            songs: JSON.stringify(results)
                        });
                    }
                }
            }
        }
    });
}

// gets recent song picks
function getClubAlbumPicks(con, event, callback) {
    const sql = 'SELECT item.item_id, item.is_album, item.item_name, item.item_artist, item.item_spotify_id, pick.pick_id '
        + 'FROM item '
        + 'JOIN pick on (item_id)'
        + 'WHERE is_album = 1';

    con.query(sql, function (error, results) {
        if (error) {
            callback(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
        } else {
            if (results.length === 0) {
                callback({
                    statusCode: "200",
                    message: "Successfully retrieved recent album picks",
                    songs: JSON.stringify(results)
                });
            } else {
                for (let i = 0; i < results.length; i++) {
                    let pick = results[i];
                    getPickVotes(pick["pick_id"], con, function (response) {
                        results[pick].add({
                            "votes": response
                        });
                    });


                    if (i === results.length - 1) {
                        callback({
                            statusCode: "200",
                            message: "Successfully retrieved recent album picks",
                            songs: JSON.stringify(results)
                        });
                    }
                }
            }
        }
    });
}




/*
 ****************** POST METHODS ***************
 */

// validates that the user with the specified name and nuid exists, and generates an
// authorization token for the user if so
function postAuthorization(con, event, callback) {

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
                    "user": results[0]
                });
            }
        });
    }

    // sql query to generate an authorization token for the user
    function insertAuthorizationToken(user, callbackLocal) {
        const uuid = UUID4();
        const structure2 = 'UPDATE user '
            + 'SET authorization = ? '
            + 'WHERE user_id = ?';
        const inserts2 = [uuid, user["user_id"]];
        const sql2 = MySQL.format(structure2, inserts2);

        // attempts to insert the authorization token
        con.query(sql2, function (error) {
            if (error) {
                callbackLocal(createErrorMessage("404", "Authorization Error", "failed to update authorization token due to server-side error", error));
            } else {
                callbackLocal({
                    "statusCode": "200",
                    "Message": "Successfully created authorization token",
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

/*
 ****************** DELETE METHODS ***************
 */


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
function jsonFormat(statusCode, body) {
    return {
        "statusCode": statusCode,
        "body": JSON.stringify(body),
        "headers": {'Content-Type': 'application/json'}
    };
}

// Gets all votes of a pick
function getPickVotes(pick_id, con, callback) {

    // gets upvotes and downvotes for this item
    let upVotePromise = new Promise(function(resolve, reject) {
        getUpVotes(function (upvotes) {
            if (upvotes.statusCode === "200") {
                resolve(upvotes)
            } else {
                reject(upvotes);
            }
        })
    });

    // gets upvotes and downvotes for this item
    let downVotePromise = new Promise(function(resolve, reject) {
        getDownVotes(function (downvotes) {
            if (downvotes.statusCode === "200") {
                resolve(downvotes)
            } else {
                reject(downvotes);
            }
        })
    });

    callback(Promise.all([upVotePromise, downVotePromise])).then(values => {
        return {
            "statusCode": "200",
            "voteData": values[0].votes.length + values[1].votes.length,
            "upVotes": values[0],
            "downVotes": values[1]
        }
    }).catch(error => {
        return createErrorMessage("404", "Server-side Error", "Failed to execute request due to unknown exception", error);
    });

    // gets all up votes for this item
    function getUpVotes() {
        const structure = 'SELECT * '
            + 'FROM votes '
            + 'JOIN pick on (pick_id) '
            + 'WHERE vote.up = 1 and pick_id = ?';
        const inserts = [pick_id];
        const sql = MySQL.format(structure, inserts);

        con.query(sql, function (error, results) {
            if (error) {
                callback(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
            } else {
                callback({
                    statusCode: "200",
                    message: "Successfully retrieved pick up votes",
                    votes: JSON.stringify(results)
                });
            }
        });
    }

    // gets all down votes for this item
    function getDownVotes() {
        const structure = 'SELECT * '
            + 'FROM votes '
            + 'JOIN pick on (pick_id) '
            + 'WHERE vote.up = 0 and pick_id = ?';
        const inserts = [pick_id];
        const sql = MySQL.format(structure, inserts);

        con.query(sql, function (error, results) {
            if (error) {
                callback(createErrorMessage("404", "Server-side Error", "Failed to query requested data due to server-side error", error));
            } else {
                callback({
                    statusCode: "200",
                    message: "Successfully retrieved pick down votes",
                    votes: JSON.stringify(results)
                });
            }
        });
    }
}
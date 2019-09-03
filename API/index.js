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
    //      'Error': '<error general message>',
    //      'Description': '<error detailed description>',
    //      'Stack Trace': '<error stack trace>'
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
                    authorizeRequest(con, path, function (response2) {
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
        return jsonFormat(404, {
            "statusCode": "404",
            "Error": "Server-side error",
            "Description": "Unknown exception occurred",
            "Stack Trace": error
        });
    });
};

// creates an instance of the database and makes a connection to it
function establishDatabaseConnection(callbackLocal) {
    // prints the event input

    //for remote use

    // creates mysql connection using environment variables
    const con = MySQL.createConnection({
        "host": process.env.host,
        "user": process.env.user,
        "password": process.env.password,
        "database": process.env.database
    });

    // for local use

    // creates mysql connection using environment variables
    /*const json = require('/Users/markpreschern/Documents/env.json');
    const con = MySQL.createConnection({
        host: json.host,
        user: json.user,
        password: json.password,
        database: json.database
    });*/

    // attempts to connect to the database
    con.connect(function (error) {
        if (error) {
            return callbackLocal({
                "statusCode": "404",
                "Error": "Connection Error",
                "Description": "Failed to connect to database",
                "Stack Trace": error
            }, con);
        } else {
            return callbackLocal({
                "statusCode": "200",
            }, con);
        }
    });
};

// verifies that the request is authorized by validating the user's authorization token
function authorizeRequest(con, path, callbackLocal) {
    // JSON Data Header: for all methods except postAuthorization
    // {
    //  headers: {
    //      authorization: <token>
    //      userid: <user_id>
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
        const inserts = [event.headers.authorization, event.headers.userid];
        const sql = MySQL.format(structure, inserts);

        // attempts to query the sql statement
        con.query(sql, function (error, results) {
            if (error) {
                return callbackLocal({
                    "statusCode": "404",
                    "Error": "Authorization Error",
                    "Description": "failed to authorize user due to server-side error",
                    "Stack Trace": error
                });
            }

            if (results.length === 0) { // invalid authorization token
                return callbackLocal({
                    "statusCode": "404",
                    "Error": "Authorization Error",
                    "Description": "failed to authorize user due to invalid authorization credentials",
                    "Stack Trace": error
                });
            } else { // valid authorization token
                return callbackLocal({
                    "statusCode": 200
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
    callback(eval(functionName)(con, event));
}


/*
 ****************** GET METHODS ***************
 */


/*
 ****************** POST METHODS ***************
 */

// validates that the user with the specified name and nuid exists, and generates an
// authorization token for the user if so
function postAuthorization(con, event) {

    // validates the user and updates their validation token
    return new Promise(function(resolve, reject) {
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
        return {
            "statusCode": "404",
            "Error": "Server-side error",
            "Description": "Failed to execute request due to unknown exception",
            "Stack Trace": error
        };
    });

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
                return callbackLocal({
                    "statusCode": "404",
                    "Error": "User Validation Error",
                    "Description": "failed to validate user due to server-side error",
                    "Stack Trace": error
                });
            } else if (results.length === 0) { // invalid login credentials
                return callbackLocal({
                    "statusCode": "404",
                    "Error": "User Validation Error",
                    "Description": "failed to validate user due to invalid login credentials",
                    "Stack Trace": error
                });
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
                callbackLocal({
                    "statusCode": "404",
                    "Error": "Authorization Error",
                    "Description": "failed to update authorization token due to server-side error",
                    "Stack Trace": error
                });
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

// TODO: Generalize querySQL and applySQL for get/post functions (aside from obtaining an authorization token
// TODO: as there is more complexity) to streamline functions

/*
// returns a response with the results of the query as the body of the JSON
// data, a success or failure code and message
function querySQL(sql, successMessage) {
    const res = con.query(sql); // error handling

    // if error :
    // statusCode: 503
    // statusMessage: Service unavailable, encountered an internal database error

    return {
        statusCode: 200,
        statusMessage: 'Success: ' + successMessage,
        body: JSON.stringify(res) // get data from res
    };
}

// returns a response with a success or failure code and message
function applySQL(sql, successMessage) {
    const res = con.query(sql); // error handling

    return {
        statusCode: 200,
        statusMessage: 'Success: ' + successMessage,
    };
}
 */

// json/application return format
function jsonFormat(statusCode, body) {
    return {
        "statusCode": statusCode,
        "body": JSON.stringify(body),
        "headers": {'Content-Type': 'application/json'}
    };
}
// Music Appreciation Club API
exports.handler = async (event, context, callback) => {

    // prints the event
    console.log('\nEvent: ' + JSON.stringify(event, null, 2) + "\n");

    // imports and configures mysql, aws-sdk, and uuid
    const MySQL = require('mysql');
    const AWS = require('aws-sdk');
    const UUID4 = require('uuid4');
    AWS.config.update({ region: 'us-east-2' });

    // sql connection
    let con;

    // creates database connection, authorizes the request, and executes the specified request respectively
    // response is of the form if successful:
    // {
    //      'Status': '200'
    // }
    // response is of the form if an error occurred:
    // {
    //      'Status': '<error status>',
    //      'Error': '<error general message>',
    //      'Description': '<error detailed description>',
    //      'Stack Trace': '<error stack trace>'
    // }
    establishDatabaseConnection(function(response1, sqlConnection) {
        if (response1.Status === "200") {
            console.log("Established Database Connection");
            con = sqlConnection;
            authorizeRequest(function (response2) {
                if (response2.Status === "200") {
                    console.log("Authorized Request");
                    executeRequest();
                } else {
                    return callback(response2);
                }
            });
        } else {
            return callback(response1);
        }
    });

    // creates an instance of the database and makes a connection to it
    function establishDatabaseConnection(callbackLocal) {
        // prints the event input

        //for remote use

        // creates mysql connection using environment variables
        /*const con = MySQL.createConnection({
            host: decrypt(process.env['host']),
            user: decrypt(process.env['user']),
            password: decrypt(process.env['password']),
            database: decrypt(process.env['database'])
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
                return callbackLocal({
                    "Status": "404",
                    "Error": "Connection Error",
                    "Description": "Failed to connect to database",
                    "Stack Trace": error
                }, con);
            } else {
                return callbackLocal({
                    "Status": "200",
                }, con);
            }
        });
    }

    // verifies that the request is authorized by validating the user's authorization token
    function authorizeRequest(callbackLocal) {
        // JSON Data Header: for all methods except postAuthorization
        // {
        //  Headers: {
        //      authorization: <token>
        //      userid: <user_id>
        // }
        // }

        // Verify authorization token if not requesting for one
        if (event.input.path === "authorization") {
            return callbackLocal({
                "Status": "200" // requesting authorization token
            });
        } else {
            // constructs the sql statement
            const structure = 'SELECT * '
                + 'FROM user '
                + 'WHERE authorization = ? and user_id = ?';
            const inserts = [event.headers.authorization, event.headers.userid];
            const sql = MySQL.format(structure, inserts);

            // attempts to query the sql statement
            con.query(sql, function(error, results) {
                if (error) {
                    return callbackLocal({
                        "Status": "404",
                        "Error": "Authorization Error",
                        "Description": "failed to authorize user due to server-side error",
                        "Stack Trace": error
                    });
                }

                if (results.length === 0) { // invalid authorization token
                    return callbackLocal({
                        "Status": "404",
                        "Error": "Authorization Error",
                        "Description": "failed to authorize user due to invalid authorization credentials",
                        "Stack Trace": error
                    });
                } else { // valid authorization token
                    return callbackLocal({
                        "Status": 200
                    });
                }
            });
        }
    }

    // executes the provided event request
    // HTTP Request Format: http://com.mac.api/requestPath/
    // - where 'requestPath' is part of the function call
    function executeRequest() {
        const functionName = event.input.httpMethod.toLowerCase()
            + event.input.path.charAt(0).toUpperCase()
            + event.input.path.slice(1);

        eval(functionName)();
    }


    /*
     ****************** GET METHODS ***************
     */


    /*
     ****************** POST METHODS ***************
     */

    // validates that the user with the specified name and nuid exists, and generates an
    // authorization token for the user if so
    function postAuthorization() {

        // validates the user and updates their validation token
        validateUser(function(response) {
            if (response.Status === "200") {
                insertAuthorizationToken(response.userId);
            } else {
                return callback(response);
            }
        });

        // sql query to validate that the user exists
        function validateUser(callbackLocal) {
            const structure1 = 'SELECT user_id '
                + 'FROM user '
                + 'WHERE name = ? AND nuid LIKE ?';
            const inserts1 = [event.headers.name, event.headers.nuid];
            const sql1 = MySQL.format(structure1, inserts1);

            // gets the user's id if they exist
            con.query(sql1, function (error, results) {
                if (error) {
                    return callbackLocal({
                        "Status": "404",
                        "Error": "User Validation Error",
                        "Description": "failed to validate user due to server-side error",
                        "Stack Trace": error
                    });
                }

                // console.log(results);

                if (results.length === 0) { // invalid login credentials
                    return callbackLocal({
                        "Status": "404",
                        "Error": "User Validation Error",
                        "Description": "failed to validate user due to invalid login credentials",
                        "Stack Trace": error
                    });
                } else { // valid login credentials
                    return callbackLocal({
                        "Status": "200",
                        "userId": results[0]["user_id"]
                    });
                }
            });
        }

        // sql query to generate an authorization token for the user
        function insertAuthorizationToken(user_id) {
            const structure2 = 'UPDATE user '
                + 'SET authorization = ? '
                + 'WHERE user_id = ?';
            const inserts2 = [UUID4(), user_id];
            const sql2 = MySQL.format(structure2, inserts2);

            // attempts to insert the authorization token
            con.query(sql2, function (error) {
                if (error) {
                    return callback({
                        "Status": "404",
                        "Error": "User Validation Error",
                        "Description": "failed to validate user due to server-side error",
                        "Stack Trace": error
                    });
                } else {
                    return callback({
                        "Status": "200",
                        "Message": "Successfully created authorization token"
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

    // decrypts the provided key-value pair encrypted value
    function decrypt(encrypted) {
        const kms = new AWS.KMS();
        kms.decrypt({ CiphertextBlob: new Buffer(encrypted, 'base64') }, (err, data) => {
            if (err) {
                alert('Decrypt error: ' + err);
            }
            return data.Plaintext.toString('ascii');
        });
    }
};

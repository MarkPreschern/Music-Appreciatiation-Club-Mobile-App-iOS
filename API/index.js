// Music Appreciation Club API
exports.handler = async (event) => {

    // prints the event input
    console.log('\nEvent: ' + JSON.stringify(event, null, 2) + "\n");

    /*
     ****************** DATABASE AUTHENTICATION ******************
     */

    // configures mysql and aws-sdk
    const mysql = require('mysql');
    const AWS = require('aws-sdk');
    AWS.config.update({ region: 'us-east-2' });

    // creates mysql connection using environment variables
    const con = mysql.createConnection({
        host: this.decrypt(process.env['host']),
        user: this.decrypt(process.env['user']),
        password: this.decrypt(process.env['password']),
        database: this.decrypt(process.env['database'])
    });

    // attempts to connect to the database
    con.connect(function(error) {
        if (!!error) {
            alert(error);
        }
    });

    /*
 ****************** EVENT AUTHORIZATION ******************
 */

    // HTTP Request Format: http://com.mac.api/requestPath/
    // - where 'requestPath' is the function call
    //
    // JSON Data Header: for all methods except postAuthorization
    // {
    //  Headers: {
    //      authorization: <token>
    //      userid: <user_id>
    // }
    // }

    // Verify authorization token if not requesting for one
    if (event.path !== 'authorization') {
        // TODO : error handling for sql query
        const sql = 'SELECT * '
            + 'FROM user '
            + 'WHERE authorization = ' + event.header.authorization + ' and user_id = ' + event.header['userid'];

        const query = con.query(sql); // if the output size is greater than zero, procede. If not, return an authorization error.
        if (query.size === 0) {
            alert('TODO: ERROR');
        }
    }

    /*
     ****************** ENTRY POINT FOR THE API ***************
     */

    // calls the function equivalent to the http request path
    console.log(event.path);
    window.settings = {
        // function names are of the form: '<httpmethod> + <path where first letter is capitalized'>
        functionName: event.httpmethod.toLowerCase() + event.path.charAt(0).toUpperCase() + event.path.slice(1)
    };
    var fn = window[window.settings.functionName];
    if(typeof fn === 'function') {
        fn();
    }


    /*
     ****************** GET METHODS ***************
     */


    /*
     ****************** POST METHODS ***************
     */

    // Gets the user with the provided user_id
    function postAuthorization() {

        // TODO: INSERT INTO USER IF USER EXISTS

        const sql =
            'SELECT * '
            + 'FROM user '
            + 'WHERE name = ' + event.header['name'] + ' AND nuid LIKE ' + event.header['nuid'];
        const successMessage = 'Successfully created authorization token';
        con.query(sql); // error handling
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
}

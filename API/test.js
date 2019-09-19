// test event data
let eventData =
    {
        "body": "item_artist=Optional%28%22Hozier%22%29&item_is_album=0&item_name=Optional%28%22Almost%20%28Sweet%20Music%29%22%29&item_id=Optional%28%225Apvsk0suoivI1H8CmBglv%22%29",
        "resource": "/API/PATH",
        "path": "/api.mac.com/userSongPicks",
        "httpMethod": "GET",
        "headers": {
            "user_id":"1",
            "authorization_token":"c1c5bb4c-c8ba-45ab-be63-ff538bf5b406",
        },
        "queryStringParameters": null,
        "multiValueQueryStringParameters": null,
        "pathParameters": null,
        "stageVariables": null,
        "requestContext": {
            "resourceId": "xxxxx",
            "resourcePath": "/api/endpoint",
            "httpMethod": "POST",
            "extendedRequestId": "xxXXxxXXw=",
            "requestTime": "29/Nov/2018:19:21:07 +0000",
            "path": "/env/api/endpoint",
            "accountId": "XXXXXX",
            "protocol": "HTTP/1.1",
            "stage": "env",
            "domainPrefix": "xxxxx",
            "requestTimeEpoch": 1543519267874,
            "requestId": "xxxxxxx-XXXX-xxxx-86a8-xxxxxa",
            "domainName": "url.us-east-1.amazonaws.com",
            "apiId": "xxxxx"
        },
    };

// import main file of lambda
let handler = require('./index');

// call exports function with required params in AWS lambda
new Promise(function (resolve) {
    resolve(handler.handler(eventData));
}).then(data => {
    console.log(data);
});

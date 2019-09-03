// test event data
let eventData =
    {
        "resource": "/API/PATH",
        "path": "/api.mac.com/authorization",
        "httpMethod": "POST",
        "headers": {
            "name":"test",
            "nuid":"test1"
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

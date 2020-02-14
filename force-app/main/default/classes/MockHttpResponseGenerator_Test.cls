@isTest
global class MockHttpResponseGenerator_Test implements HttpCalloutMock {
    //Implement the HttpCalloutMock interface method respond
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake http response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"message":"Test Http Callout"}');
        res.setStatusCode(200);
        return res;
    }
}
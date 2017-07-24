# RESTAPI
Lightweight REST API communicator written in Swift, based on Foundation.
An easy tool to communicate with your server's API in JSON format. Supports querys and valid JSON objects in the HTTP body.

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/Gujci/RESTAPI.svg?branch=master)](https://travis-ci.org/Gujci/RESTAPI)

The framework supports `GET`, `POST`, `PUT` and `DELETE` requests for now.

`PATCH` is added at **0.6.0**, maybe it's not so RESTful, but you have it.

# Installation
## Carthage
```
github "Gujci/RESTAPI"
```

This framework highly relies on [SwiftyJSON] (https://github.com/SwiftyJSON/SwiftyJSON), so it imports it.

### Swift 2.2

for Swift 2.2 use the `0.2.2` tag. This version will not be supported.

```
github "Gujci/RESTAPI" "== 0.2.2"
```
## CocoaPods
```
pod 'RESTAPI'
```

# Examples

### Simple request

By default you can perform a single request which returns a simple JSON response.

```swift
let testServerApi = API(withBaseUrl: "http://jsonplaceholder.typicode.com")
testServerApi.get("/posts") { (error, data) in
    //This data will be SwiftyJSON's Optional JSON type by default (data: JSON?)
}
```
Or if you want to, you can get a parsed response type with the same request.

### Request with expected response type

First you have to implement your response type, which must comform to `JSONParseable` protocol.

```swift
struct ExampleResponse: JSONParseable {
    var body: String
    var id: Int
    var title: String
    var userId: Int
    
    init(withJSON data: JSON) {
        body = data["body"].stringValue
        id = data["id"].intValue
        title = data["title"].stringValue
        userId = data["userId"].intValue
    }
}
```

After implementing the response object, you have to set the type of the expected response data in the completion's parameter list like this.

```swift
testServerApi.get("/posts") { (error, data: [ExampleResponse]?) in
    //This a swift array now, filled with ExampleResponse instances
}
```

In this case an array was expected as response, but simple types will work as well (like `ExampleResponse?`). It's important that you mark your parameter as optional, otherwise you will get a compile time error.

### Querying

Querying is simple like this:

```swift
testServerApi.get("/posts", query: ["userId" : "1"]) { (error, object: [ExampleResponse]?) in
    //...
}
```

Values in the query parameter dictionary must implement the `Queryable` protocol, `String` and `Array` types implement this by default.

### Body parameters

```swift
testServerApi.post("/posts", data: ["body": "something","id": 1, "title": "Some title", "userId": 9]) { (error, object) in
    //...
}
```
Body parameters should comform to `ValidJSONObject` protocol. `Array` and `Dictionary` types implement this by default.
Any custom type can implement `ValidJSONObject`, which requres a function that converts your type to `Data`.

```swift
func JSONFormat() throws -> Data
```

If you don't want that much controll and resposibility, you can implement `JSONConvertible`, which has a property named `parameterValue` which can be any `ValidJSONObject`. Practically you just have to convert your type to a `Dictionary` or an other `ValidJSONObject` just it like this:

```swift
struct ExampleData {
    var body: String
    var id: Int
    var title: String
    var userId: Int
}

extension ExampleData: JSONConvertible {
    // this is valid json
    var parameterValue: [String: Any] {
        return ["body": body, "id": id, "title": title, "userId": userId]
    }
}
```
Additional fields can be added anytime to this property, also, you can exclude any properties. After implementing it, uploading is simple:

```swift
var uploadData = ExampleData(body: "body", id: 1, title: "title", userId: 2)

testServerApi.post("/posts", data: uploadData) { (error, object) in
    //...
}
```

### Authenticating requests

To authenticate a request, you have to set the `authentication` property of the API instance. For now this framework supports simple,  access token based authentications in HTTP header and URL query. This is a simple example to show how to set up a HTTP header based authentication.

```swift
var accessToken: String?

var sessionAuthenticator: RequestAuthenticator {
    let auth = RequestAuthenticator()
    auth.tokenKey = "access_token"
    if let validToken = self.accessToken {
        auth.type = .HTTPHeader
        auth.accessToken = validToken
    }
    else {
        auth.type = .None
    }
    return auth
}
//...
    testServerApi.authentication = sessionAuthenticator
//...
```

# TODO list

## 1.0
- [x] Document the authentication
- [x] Carthage support
- [x] CocoaPods support
- [x] expand error types to almost full
- [ ] make JSON and [JSON] comform to JSONParseable to reduce redundant code
- [ ] Add more unit tests
- [x] Travis
- [ ] Document form-encoded-support related changes

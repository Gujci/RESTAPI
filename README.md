# RESTAPI
Lightweight REST API communicator written in Swift, based on Foundation.
An easy tool to communicate with your server's API in JSON format. Supports querys and valid JSON objects in the HTTP body.

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# Installation
## Carthage
```
github "Gujci/RESTAPI"
```

This framework highly relies on [SwiftyJSON] (https://github.com/SwiftyJSON/SwiftyJSON), so you might want to install it as well.
```
github "SwiftyJSON/SwiftyJSON"
```

# Example
By default you can perform a single request which returns a simple JSON response.

```swift
let testServerApi = API(withBaseUrl: "http://jsonplaceholder.typicode.com")
testServerApi.get("/posts") { (error, data) in
    //This data will be SwiftyJSON's Optional JSON type by default (data: JSON?)
}
```
Or if you want to, you can get a parsed response type with the same request.

First you have to implement your response type, which must comform to JSONParseable protocol.

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

After implementing the response object, you have toset the type of the desired response data in the completion's parameter list like this.

```swift
testServerApi.get("/posts") { (error, data: [ExampleResponse]?) in
    //This a swift array now, filled with ExampleResponse instances
}
```

In this case an array was expected as response, but simple types will work as well (like ExampleResponse?). It's important that you mark your parameter as Optional, otherwise you will get a compile time error.

The framework Supports GET, POST, PUT and DELETE requests for now.

More documentation for querys and HTTP body params coming soon...

# TODO list
- [ ] Document the API
- [x] Carthage support
- [ ] Complete the TODOs in the code
- [ ] Add other possibble authentication types
- [ ] Add unit tests

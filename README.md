# RESTAPI
Lightweight REST API communicator written in Swift, based on Foundation.
An easy tool to communicate with your server's API in JSON format. Supports querys and valid JSON objects in the HTTP body. 

# Basic example usage
```swift
let testServerApi = API(withBaseUrl: "http://jsonplaceholder.typicode.com")
testServerApi.get("/posts") { (error, object) in
    //...
}
```

# TODO
- [ ] Document the API
- [ ] Add (or fix) Carthage support
- [ ] Complete the TODOs in the code
- [ ] Add other possibble authentication types
- [ ] Add unit tests

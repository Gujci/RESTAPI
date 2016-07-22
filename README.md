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

# Basic example usage
```swift
let testServerApi = API(withBaseUrl: "http://jsonplaceholder.typicode.com")
testServerApi.get("/posts") { (error, object) in
    //...
}
```

# TODO list
- [ ] Document the API
- [x] Carthage support
- [ ] Complete the TODOs in the code
- [ ] Add other possibble authentication types
- [ ] Add unit tests

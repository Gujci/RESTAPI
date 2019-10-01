# RESTAPI
Lightweight REST API communicator written in Swift, based on Foundation.
An easy tool to communicate with your server's API in JSON format. Supports querys and valid JSON objects in the HTTP body.

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![](https://github.com/Gujci/RESTAPI/workflows/ios-spm/badge.svg)
![](https://github.com/Gujci/RESTAPI/workflows/ios-carthage/badge.svg)


The framework supports `GET`, `POST`, `PUT` and `DELETE` requests for now.

`PATCH` is added at **0.6.0**, maybe it's not so RESTful, but you have it.

# Installation

## Swift Package Manager

```swift
.package(url: "https://github.com/Gujci/RESTAPI.git")
```

In dependenciec add `RESTAPI` or `RESTAPIImage` as well for [Image upload](Image-upload) & other image related extensions.

## Carthage

```
github "Gujci/RESTAPI"
```

Carthage dropped support for multiple frameworks / repo, so it has to be compiled on device to be able to use both `RESTAPI` and `RESTAPIImage` for [Image upload](Image-upload). 

`RESTAPIImage` is a sepatate framework, in order to use, add it to Carthage `copy-frameworks` phase and link it.

This framework highly relies on [SwiftyJSON] (https://github.com/SwiftyJSON/SwiftyJSON), so it imports it.

### Older versions

#### Swift 2.2

for Swift 2.2 use the `0.2.2` tag. This version will not be supported.

```
github "Gujci/RESTAPI" "== 0.2.2"
```

#### Swift 3

for Swift 3 use the `0.6.1` tag. This version will not be supported.

```
github "Gujci/RESTAPI" "== 0.6.1"
```

## CocoaPods

For the latest verion, use

```
pod 'RESTAPI', :git => 'https://github.com/Gujci/RESTAPI.git'
```

# Examples

##  Request

### Basic request

By default you can perform a single request which returns a simple JSON response.

```swift
let testServerApi = API(withBaseUrl: "http://jsonplaceholder.typicode.com")
testServerApi.get("/posts") { (status, data) in
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

>   `JSONParseable` is a convinience protocol, which inherits from `ValidResponseData`. Custom `ValidResponseData` can also be implemented, and requested. 

### Or by using Codable

By conforming to `Decodable` , the given type automatically conforms to `JSONCodable`, which is `ValidResponseData`.

```swift
struct ExampleResponse: Codable {
    var body: String
    var id: Int?
    var title: String
    var userId: Int
}

extension ExampleResponse: JSONCodable {}
```

After implementing the response object, you have to set the type of the expected response data in the completion's parameter list like this.

```swift
testServerApi.get("/posts") { (status, data: [ExampleResponse]?) in
    //This a swift array now, filled with ExampleResponse instances
}
```

In this case an array was expected as response, but simple types will work as well (like `ExampleResponse?`). It's important that you mark your parameter as optional, otherwise you will get a compile time error.

### Querying

Querying is simple like this:

```swift
testServerApi.get("/posts", query: ["userId" : "1"]) { (status, object: [ExampleResponse]?) in
    //...
}
```

Values in the query parameter dictionary must implement the `Queryable` protocol, `String` and `Array` types implement this by default.

## Body parameters

### Simple body

```swift
testServerApi.post("/posts", data: ["body": "something","id": 1, "title": "Some title", "userId": 9]) { (status, object) in
    //...
}
```

Body parameters should comform to `ValidJSONObject` protocol. `Array` and `Dictionary` types implement this by default.
Any custom type can implement `ValidJSONObject`, which requres a function that converts your type to `Data`.

```swift
func JSONFormat() throws -> Data
```

### Custom object in body without Codable

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

Additional fields can be added anytime to this property, also, you can exclude any properties.

### Custom object in body with Codable

By conforming to `ValidJSONData`, `Encodable` types are automatically parsed to a request json, no manual step needed. 

```swift
struct ExampleData: Codable {
    var body: String
    var id: Int?
    var title: String
    var userId: Int
}

extension ExampleData: ValidJSONData {}
```

### Upload

To upload, just pass a `ValidRequestData` to the approptiate function's data parameter.

```swift
var uploadData = ExampleData(body: "body", id: 1, title: "title", userId: 2)

testServerApi.post("/posts", data: uploadData) { (status, object) in
    //...
}
```

### Form encoded request

The framework also supports `form-encoded` requests as long as the response is in `JSON` format. To send one use a similar json request, but the body must comform to `ValidFormData` protocol.

If you want to save time, and ok with simple `[String: String]` format, just implement the `FormEncodable` protocol, which is much easyer and automatically conform to `ValidFormData`.

`Dictionary` has an added element called `formValue`, which is automatically conforms to `ValidFormData`.  This is mostly a workaruond for a problem described [later](###Disclaimer)

```swift

extension ExampleData: FormEncodable {

var parameters: [String: String] {
        return ["body": body, "id": "\(id)", "title": title, "userId": "\(userId)"]
    }
}

// ...
oldServerApi.post("/post.php", query: ["dir": "gujci_test"], data: uploadData.formValue){ (status, response) in
    // ... do something
}
```

>   No Codable support for form encoded request yet.

### Multipart form request

`MultipartFormData` is a protocol, which provides default implementation for  `ValidRequestData`. Implement this protocol to prepare any custom type to be uploaded as multipart form data.

### Cacheable

`Cacheable` is a protocol, which can be used with the `load()` function of `API`.  This enables responses (eq. images) to be cached on device. The implementation is up to the developer, on order the conform to `Cacheable` a type must implement the following methods.

```swift
static func getPersistantData(for url: String) throws -> Self?

func savePersistant(for url: String) throws
```

>   Since the only key for cache is the URL string itself, this mechanism is better for binaries like images and data, where the URL is also an identifier for a resource.

## Images

There is a separate target called `RESTAPIImage`, which contains upload and cached download implementations to supported protocols ( `Cacheable`, `MultipartFormData` ) for `UIImage`.

It also contains an extension for `UIImageView` to just pass an URL to it to set up the image:

````swift
func setup(from imageUrl: String?)
````

>   UIImage extensions only work in environments, where UIKit is available.

### Image upload

 `RESTAPIImage` adds a util implementation for  `MultipartFormData` to upload a simple image. To perform an upload, just instantiate a new `JPGUploadMultipartFormData` instance with `UIImage` and send it as any other request.

````swift
let uploadData = JPGUploadMultipartFormData(image: image, fileName: "image", uploadName: "upfile")
api.post("/me/profile_picture", data: uploadData) { (status, resp) in 
    //...
}
````

As all methods requre a  `ValidRequestData` to send in body, uploading `JPGUploadMultipartFormData` is not different from any json upload besides composing the `httpBody` of the request. Any utils like authentication can be used, the response parsing is the same.

If the `JPGUploadMultipartFormData` implemetation is not suited for the current usecase, custom implemetnation for `MultipartFormData` can be implemented easily, like described [before](###Multipart-form-request)

## Authenticating requests

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

## General body protocol

Any request body sent, must conform to `ValidRequestData` protocol. The 2 mentioned above are just some pre-implemented, widely used cases. If you use a custom protocol, or something, which is not implemented in this framework, just made the desired types conform to `ValidRequestData`, and they can be automatically used with the framework.

```swift
public protocol ValidRequestData {
    // defines the content type header
    func type() -> ContentType
    // returns the data, to sent to server
    func requestData() throws -> Data
}
```

>   One type must not implement this protocol twice or more, meaning it is not supported to conform to both `ValidFormData` and `JSONConvertible`.

## Response

A response wrapper is provided in the framework for all  `ValidResponseData` in order to parse both the success and a possible error response. However, using the same structure, you can implement any other type of generic response to match your needs. An example call with the built in one looks like the following:

```swift
testServerApi.get("/endpoint") { (status, response: Response<ExampleResponse, APIError>?) in
    //...
}
```

Where `APIError` is an other custom `ValidResponseData` type, but `JSON` is accepted as well (since it also conforms to `ValidResponseData`). Note, that array of `ValidResponseData` also conforms to `ValidResponseData`.

## Result

>  This section is about one possibble implementation to support `Result` as a callback type. These are just to suggestions to implement your own. I just put this feature on the roadmap, so hopefully, full support will be coming soon. Also keeping an eye on [async/await proposals](https://forums.swift.org/search?q=await).

Since swift 5 you may use the `Result` type as a built in solution to wrap data and error together. You may write an extension like this to be able to use the type, but it would not represent the network error only the one which may occure while parsing the response.

```swift
extension Result: ValidResponseData where Success: ValidResponseData {

    public static func createInstance(from data: Data) throws -> Result<Success, Failure> {
        do {
            return .success(try Success.createInstance(from: data))
        }
        catch let e as Failure {
            return .failure(e)
        }
    }
}
```

To make full advantage of the type the whole callback should have one `Result`  parameter.  Like the following, where `SomeResultType` can be any compatible type. Also, you may write your own `SomeErrorType` or just use `APIError`.

```swift
testServerApi.get("/posts") { (data: Result<SomeResultType, SomeErrorType>) in
    // ...
}
```

To be able to call this, you have to write a wrapper for the original function.

```swift
extension API {

    public func get<T: ValidResponseData, E: Error>(_ endpoint: String, query: [String: Queryable]? = nil, data: ValidRequestData? = nil,
        completion: @escaping (Result<T, E>) -> ()) {
            get(endpoint, query: query, data: data) { (status, response: Data?) in
                // parse status & response to Result
                if status.isSuccess,
                    let response = response,
                    let result = try? T.createInstance(from: response) {
                        completion(.success(result))
                    } else {
                        // ... custom error parsing
                    }
                }
        }
}
```

# Debugging

To turn on request logging add `APIRequestLoggingEnabled` to 'Arguments passed on launch' at Schema/Run/Arguments.

To log server sent errrors turn on  `APIErrorLoggingEnabled`.

# TODO list

## 1.0
- [x] Document the authentication
- [x] Carthage support
- [x] CocoaPods support
- [x] SPM support
- [x] Expand status types to almost full
- [x] Make JSON and [JSON] comform to JSONParseable to reduce redundant code (Solved by adding ValidResponseData & Conditional Conformance)
- [x] ~Travis~ GitHub Actions
- [x] Document form-encoded-support related changes
- [ ] Full support for some `Result` type 

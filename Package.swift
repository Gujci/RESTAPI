// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "RESTAPI",
    platforms: [
        .macOS(.v10_10), .iOS(.v8), .tvOS(.v9), .watchOS(.v3)
    ],
    products: [
        .library(name: "RESTAPI", targets: ["RESTAPI"]),
        .library(name: "RESTAPIImage", targets: ["RESTAPIImage"])
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0")
    ],
    targets: [
        .target(name: "RESTAPI", dependencies: ["SwiftyJSON"], path: "RESTAPI"),
        .testTarget(name: "RESTAPITests", dependencies: ["RESTAPI"], path: "RESTAPITests"),
        .target(name: "RESTAPIImage", dependencies: ["RESTAPI"], path: "RESTAPIImage"),
        .testTarget(name: "RESTAPIImageTests", dependencies: ["RESTAPIImage"], path: "RESTAPIImageTests")
    ]
)

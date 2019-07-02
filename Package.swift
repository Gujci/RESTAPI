// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "RESTAPI",
    products: [
        .library(name: "RESTAPI", targets: ["RESTAPI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0")
    ],
    targets: [
        .target(name: "RESTAPI", dependencies: ["SwiftyJSON"], path: "RESTAPI"),
        .testTarget(name: "RESTAPITests", dependencies: ["RESTAPI"], path: "RESTAPITests"),
    ]
)

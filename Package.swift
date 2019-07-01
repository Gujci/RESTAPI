// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "RESTAPI",
    products: [
        .library(name: "RESTAPI", targets: [.target(name: "RESTAPI",path: ".")]),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0")
    ],
    targets: [
        .target(name: "RESTAPI", dependencies: ["SwiftyJSON"]),
        .testTarget(name: "RESTAPITests", dependencies: ["RESTAPI"]),
    ]
)

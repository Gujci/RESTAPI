//
//  RESTAPITests.swift
//  RESTAPITests
//
//  Created by Gujgiczer Máté on 22/07/16.
//  Copyright © 2016 gujci. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import RESTAPI

struct ExamplePostModel {
    var body: String
    var id: Int
    var title: String
    var userId: Int
    
    init(withBody body: String, id: Int, title: String, userId: Int) {
        self.body = body
        self.id = id
        self.title = title
        self.userId = userId
    }
}

extension ExamplePostModel: JSONParseable {
    
    init(withJSON data: JSON) {
        body = data["body"].stringValue
        id = data["id"].intValue
        title = data["title"].stringValue
        userId = data["userId"].intValue
    }
}

extension ExamplePostModel: JSONConvertible {

    var parameterValue: [String: AnyObject] {
        return ["body": body, "id": NSNumber(integer: id), "title": title, "userId": NSNumber(integer: userId)]
    }
}

class RESTAPITests: XCTestCase {

    
    let testServerApi = API(withBaseUrl: "http://jsonplaceholder.typicode.com")
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let expectation = expectationWithDescription("some")
        
        testServerApi.headers["api_secret"] = "psszt"
        
        testServerApi.post("/posts",
                           data: ExamplePostModel(withBody: "something", id: 1, title: "Some title", userId: 9))
        { (error, object: ExamplePostModel?) in
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

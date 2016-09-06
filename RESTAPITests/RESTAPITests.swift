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

class RESTAPITests: XCTestCase {
    
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
        
        testServerApi.post("/posts", data: ["body": "something","id": 1, "title": "Some title", "userId": 9]) { (error, object) in
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

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
        return ["body": body as AnyObject, "id": NSNumber(value: id as Int), "title": title as AnyObject, "userId": NSNumber(value: userId as Int)]
    }
}

class RESTAPITests: XCTestCase {

    
    let testServerApi = API(withBaseUrl: "http://jsonplaceholder.typicode.com")
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testQuery() {
        let expectation = self.expectation(description: "some")
        
        testServerApi.get("/posts",
                          query: ["userId": "1"])
        { (error, object: [ExamplePostModel]?) in
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testPost() {
        let expectation = self.expectation(description: "some")
        
        testServerApi.headers["api_secret"] = "psszt"
        
        testServerApi.post("/posts",
                           data: ExamplePostModel(withBody: "something", id: 1, title: "Some title", userId: 9))
        { (error, object: ExamplePostModel?) in
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

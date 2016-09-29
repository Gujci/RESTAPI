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

//MARK: - ExamplePostModel
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

    var parameterValue: [String: Any] {
        return ["body": body, "id": id, "title": title, "userId": userId]
    }
}

//MARK: - Test class
class RESTAPITests: XCTestCase {

    let testServerApi = API(withBaseUrl: "http://jsonplaceholder.typicode.com")
    
    func testQuery() {
        let expectation = self.expectation(description: "some")
        
        testServerApi.get("/posts", query: ["userId": "1"])
        { (error, posts: [ExamplePostModel]?) in
            posts?.forEach() { post in
                XCTAssert(post.userId == 1)
            }
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
        let example = ExamplePostModel(withBody: "something", id: 1, title: "Some title", userId: 9)
        
        testServerApi.post("/posts", data: example){ (error, responsePost: ExamplePostModel?) in
            XCTAssertEqual(responsePost?.id, example.id)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

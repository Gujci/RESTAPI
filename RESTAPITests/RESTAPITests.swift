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
    var id: Int?
    var title: String
    var userId: Int
    
    init(withBody body: String, title: String, userId: Int) {
        self.body = body
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
        return ["body": body, "title": title, "userId": userId]
    }
}

//MARK: - Test class
class RESTAPITests: XCTestCase {

    let testServerApi = API(withBaseUrl: "http://jsonplaceholder.typicode.com")
    
    func testGetArray() {
        let expectation = self.expectation(description: "get")
        
        testServerApi.get("/posts") { (error, posts: [ExamplePostModel]?) in
            XCTAssertNotNil(posts)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testPostAndPatch() {
        let expectation = self.expectation(description: "post&patch")
        let example = ExamplePostModel(withBody: "something", title: "Some title", userId: 9)
        
        testServerApi.post("/posts", data: example){ (error, responsePost: ExamplePostModel?) in
            guard let _ = responsePost?.id else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(example.body, responsePost?.body)
            XCTAssertEqual(example.title, responsePost?.title)
            XCTAssertEqual(example.userId, responsePost?.userId)
            
            self.testServerApi.patch("/posts/1", data: ["title": "Other title"]) { (error,  responsePost: ExamplePostModel?) in
                XCTAssertEqual(responsePost?.title, "Other title")
                expectation.fulfill()
            }
        }
        
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testQuery() {
        let expectation = self.expectation(description: "querry")
        
        testServerApi.get("/posts", query: ["userId": "1"]) { (error, posts: [ExamplePostModel]?) in
            XCTAssertNotNil(posts)
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
    
    func testError() {
        let expectation = self.expectation(description: "error")
        
        testServerApi.put("/posts/undefined") { (error, posts: JSON?) in
            guard let err = error, err == APIError.notFound else { return }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testFormPost() {
        let expectation = self.expectation(description: "form post")
        let legacyServerApi = API(withBaseUrl: "https://posttestserver.com")
        
        legacyServerApi.post("/post.php", query: ["dir": "gujci_test"],
                             data: ["key": "value", "body": "any"].formValue){ (error, response: JSON?) in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

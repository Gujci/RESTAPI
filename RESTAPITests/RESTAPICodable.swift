//
//  RESTAPICodable.swift
//  RESTAPI iOS
//
//  Created by Gujgiczer Máté on 2018. 11. 09..
//  Copyright © 2018. gujci. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import RESTAPI

struct CodablePostModel: Codable {
    var body: String
    var id: Int?
    var title: String
    var userId: Int
}

extension CodablePostModel: JSONCodable {}

extension CodablePostModel: ValidJSONData {}

class RESTAPICodableTests: XCTestCase {
    
    let testServerApi = API(withBaseUrl: "http://jsonplaceholder.typicode.com")
    
    func testGetArray() {
        let expectation = self.expectation(description: "get")
        
        testServerApi.get("/posts") { (error, posts: [CodablePostModel]?) in
            XCTAssertNotNil(posts)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testPost() {
        let expectation = self.expectation(description: "post")
        let example = CodablePostModel(body: "Some body", id: nil, title: "🎉 Working", userId: 1)
        
        testServerApi.post("/posts", data: example) { (error, response: CodablePostModel?) in
            XCTAssertEqual(example.body, response?.body)
            XCTAssertEqual(example.title, response?.title)
            XCTAssertEqual(example.userId, response?.userId)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

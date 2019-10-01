//
//  RESTAPIImageTests.swift
//  RESTAPIImageTests
//
//  Created by Gujgiczer Máté on 2018. 09. 25..
//  Copyright © 2018. gujci. All rights reserved.
//

#if !os(watchOS) && !os(macOS)
import XCTest
@testable import RESTAPI
@testable import RESTAPIImage

class RESTAPIImageTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testBinaryCache() {
           let expectation = self.expectation(description: "cache")
            let loader = API(withBaseUrl: "")
           
            loader.load(from: "https://picsum.photos/200/300") { (data: UIImage?) in
               XCTAssertNotNil(data)
               expectation.fulfill()
           }
           
           waitForExpectations(timeout: 30) { error in
               if let error = error {
                   print("Error: \(error.localizedDescription)")
               }
           }
       }
}
#endif

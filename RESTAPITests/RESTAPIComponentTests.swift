//
//  RESTAPIComponentTests.swift
//  RESTAPI iOSTests
//
//  Created by Gujgiczer Máté on 2018. 11. 06..
//  Copyright © 2018. gujci. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import RESTAPI

class RESTAPIComponentTests: XCTestCase {

    func testComplexQuery() {
        let testDict = ["level1_0": "key1", "level1_1": ["array1", "array2"]] as [String : Any]
        let desiredQueryString = "&test[level1_0]=key1&test[level1_1][]=array1&test[level1_1][]=array2"
        let query = testDict.queryString(forKey: "test").reduce("") { acc, it in acc + "&\(it.name)=\(it.value ?? "")"}
        XCTAssertEqual(desiredQueryString, query)
    }
    
    func testDeepComplexQuery() {
        let testDict = ["level_0": ["level1_0": "key1", "level1_1": ["array1", "array2"]]] as [String : Any]
        let desiredQueryString = "&test[level_0][level1_0]=key1&test[level_0][level1_1][]=array1&test[level_0][level1_1][]=array2"
        let query = testDict.queryString(forKey: "test").reduce("") { acc, it in acc + "&\(it.name)=\(it.value ?? "")"}
        XCTAssertEqual(desiredQueryString, query)
    }
}

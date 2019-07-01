//
//  API+JSONConvertible.swift
//  RESTAPI
//
//  Created by Gujgiczer Máté on 12/09/16.
//  Copyright © 2016 gujci. All rights reserved.
//

import Foundation
import SwiftyJSON

// MARK: - JSON encoding
/// Protocol for objects that can be converted to JSONs for HTTP body parameters
public protocol ValidJSONData: ValidRequestData {
    func JSONFormat() throws -> Data
}

// MARK: - Conformance to ValidRequestData
public extension ValidJSONData {
    
    func type() -> ContentType { return .json }
    
    func requestData() throws -> Data { return try JSONFormat() }
}

// MARK: - JSONConvertible
public protocol JSONConvertible: ValidJSONData {
    associatedtype T: ValidJSONData
    var parameterValue: T {get}
}

public extension JSONConvertible  {
    
    func JSONFormat() throws -> Data { return try parameterValue.JSONFormat() }
}

// MARK: - Default Implemetations
extension Dictionary: ValidJSONData {
    public func JSONFormat() throws -> Data {
        return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
    }
}

extension Array: ValidJSONData {
    public func JSONFormat() throws -> Data {
        return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
    }
}

extension String: ValidJSONData {
    public func JSONFormat() throws -> Data {
        return self.data(using: String.Encoding.utf8)!
    }
}

public extension ValidJSONData where Self: Encodable {
    
    func JSONFormat() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
}


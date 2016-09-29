//
//  API+JSONConvertible.swift
//  RESTAPI
//
//  Created by Gujgiczer Máté on 12/09/16.
//  Copyright © 2016 gujci. All rights reserved.
//

import SwiftyJSON

/// Converting to JSON error type
public enum ValidJSONObjectParseError: Error {
    case jsonSerializeError
}

/// Protocol for objects that can be converted to JSONs for HTTP body parameters
public protocol ValidJSONObject {
    func JSONFormat() throws -> Data
}

/// Protocol for custom types
public protocol JSONConvertible: ValidJSONObject {
    associatedtype T: ValidJSONObject
    var parameterValue: T {get}
}

public extension JSONConvertible  {
    func JSONFormat() throws -> Data {
        return try parameterValue.JSONFormat()
    }
}

//MARK: - default Implemetations
extension Dictionary: ValidJSONObject {
    public func JSONFormat() throws -> Data {
        return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
    }
}

extension Array: ValidJSONObject {
    public func JSONFormat() throws -> Data {
        return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
    }
}

extension String: ValidJSONObject {
    public func JSONFormat() throws -> Data {
        return self.data(using: String.Encoding.utf8)!
    }
}

//
//  API+JSONConvertible.swift
//  RESTAPI
//
//  Created by Gujgiczer Máté on 12/09/16.
//  Copyright © 2016 gujci. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Converting to JSON error type
public enum ValidJSONObjectParseError: ErrorType {
    case JSONSerializeError
}

/// Protocol for objects that can be converted to JSONs for HTTP body parameters
public protocol ValidJSONObject {
    func JSONFormat() throws -> NSData
}

public protocol JSONConvertible: ValidJSONObject {
    associatedtype T: ValidJSONObject
    var parameterValue: T {get}
}

extension JSONConvertible  {
    func JSONFormat() throws -> NSData {
        return try parameterValue.JSONFormat()
    }
}

//MARK: - default Implemetations
extension Dictionary: ValidJSONObject {
    public func JSONFormat() throws -> NSData {
        if let serializableData = self as? AnyObject {
            return try NSJSONSerialization.dataWithJSONObject(serializableData, options: .PrettyPrinted)
        }
        else {
            throw ValidJSONObjectParseError.JSONSerializeError
        }
    }
}

extension Array: ValidJSONObject {
    public func JSONFormat() throws -> NSData {
        if let serializableData = self as? AnyObject {
            return try NSJSONSerialization.dataWithJSONObject(serializableData, options: .PrettyPrinted)
        }
        else {
            throw ValidJSONObjectParseError.JSONSerializeError
        }
    }
}

extension String: ValidJSONObject {
    public func JSONFormat() throws -> NSData {
        return self.dataUsingEncoding(NSUTF8StringEncoding)!
    }
}

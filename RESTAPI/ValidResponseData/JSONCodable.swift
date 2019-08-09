//
//  JSONCodable.swift
//
//  Created by Gujgiczer Máté on 23/03/16.
//

import Foundation
import SwiftyJSON

public struct JSONDecoderStore {
    
    private static var storage: [String: JSONDecoder] = [:]
    
    public static let defaultDecoder = JSONDecoder()
    
    public static subscript(_ type: JSONCodable.Type) -> JSONDecoder {
        get { storage[String(describing: type)] ?? defaultDecoder }
        set { storage[String(describing: type)] = newValue}
    }
}

public protocol JSONCodable: ValidResponseData { }

public extension JSONCodable where Self: Decodable {
    
    static func createInstance(from data: Data) throws -> Self {
        return try JSONDecoderStore[Self].decode(Self.self, from: data)
    }
}

public protocol JSONParseable: JSONCodable {
    init(withJSON data:JSON) throws
}

public extension JSONParseable {
    
    static func createInstance(from data: Data) throws -> Self {
        let json = try JSON(data: data)
        return try Self.init(withJSON: json)
    }
}

extension Data: ValidResponseData {
    
    public static func createInstance(from data: Data) throws -> Data { return data }
}

extension JSON: JSONCodable {
    
    public static func createInstance(from data: Data) throws -> JSON {
        return try JSON(data: data)
    }
}

extension Array: ValidResponseData where Element: JSONCodable {

    public static func createInstance(from data: Data) throws -> Array<Element> {
        return try JSON(data: data).arrayValue.map { try Element.createInstance(from: $0.rawData()) } // TODO: - back & forth?
    }
}

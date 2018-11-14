//
//  FormEncodable.swift
//  RESTAPI
//
//  Created by Gujgiczer Máté on 2017. 07. 10..
//  Copyright © 2017. gujci. All rights reserved.
//

// MARK: - Form encoding
public protocol ValidFormData: ValidRequestData {
    func formEncodedValue() throws -> Data
}

// MARK: - Conformance to ValidRequestData
public extension ValidFormData {
    
    func type() -> ContentType { return .formEncoded }

    func requestData() throws -> Data { return try formEncodedValue() }
}

// MARK: - FormEncodable
public protocol FormEncodable: ValidFormData {
    var parameters: [String: String] {get}
}

public extension FormEncodable {
    func formEncodedValue() throws -> Data {
        if let value = parameters.formEncodedString.data(using: .utf8) {
            return value
        }
        else {
            throw ObjectParseError.formencodeError
        }
    }
}


// MARK: - Default Implemetations
public extension Dictionary where Key == String, Value == String  {
    
    // Needs to be nested, since Dictionary also implements JSONConvertible, which inherits from the same protocol
    // (a.k.a there would be 2 ways to parse a dictionary automatically into a HTTP request body)
    private struct FormWraper: FormEncodable {
        public var parameters: [String: String]
    }
    
    var formValue: ValidFormData {
        return FormWraper(parameters: self)
    }
}

// MARK: - Util
private extension Dictionary where Key == String, Value == String {
    
    var formEncodedString: String {
        return self.map({
            return "\($0.key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" +
                "=" +
            "\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"})
            .joined(separator: "&")
        
    }
}

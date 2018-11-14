//
//  MultipartFormData.swift
//  RESTAPI iOS
//
//  Created by Gujgiczer Máté on 2018. 09. 25..
//  Copyright © 2018. gujci. All rights reserved.
//

public extension String {
    
    static var generatedBoudary: String { return "boundary-\(UUID().uuidString)" }
}

public struct MultipartFormDataElement {
    var name: String
    var data: ValidRequestData
    var customParams: [String: String]?
    
    public init(name: String, data: ValidRequestData, customParams: [String: String]? = nil) {
        self.name = name
        self.data = data
        self.customParams = customParams
    }
}

public protocol MultipartFormData: ValidRequestData {
    var boundary: String { get }
    var elements: [MultipartFormDataElement] { get }
}

public extension MultipartFormData {
    
    func type() -> ContentType { return .custom("multipart/form-data; boundary=\(boundary)") }
    
    func requestData() throws -> Data {
        var data = Data()
        try elements.forEach { element in
            data.append(string: "--\(boundary)\r\n")
            data.append(string: "Content-Disposition: form-data; name=\"\(element.name)\"")
            element.customParams?.forEach { data.append(string: "; \($0)=\"\($1)\"") }
            data.append(string: "\r\n")
            data.append(string: "Content-Type: \(element.data.type())\r\n")
            data.append(string: "\r\n")
            data.append(try element.data.requestData())
            data.append(string: "\r\n")
        }
        data.append(string: "--\(boundary)--\r\n")
        return data
    }
}

extension Data {
    
    mutating func append(string: String) {
        guard let stringData = string.data(using: .utf8) else { return }
        append(stringData)
    }
}

//
//  UtilTypes.swift
//  RESTAPI iOS
//
//  Created by Gujgiczer Máté on 2019. 04. 15..
//  Copyright © 2019. gujci. All rights reserved.
//
import Foundation
import SwiftyJSON

public struct Response<DataType: ValidResponseData, ErrorType: ValidResponseData>: ValidResponseData {
    public var data: DataType?
    public var error: ErrorType?
    
    public static func createInstance(from data: Data) throws -> Response<DataType, ErrorType> {
        return Response(data: try? DataType.createInstance(from: data),
                        error: try? ErrorType.createInstance(from: data))
    }
}


public struct APIError: JSONParseable, Error {
    
    public var message: String
    
    public init(withJSON data: JSON) throws {
        guard let text = data["message"].string else { throw ObjectParseError.jsonSerializeError }
        message = text
    }
}

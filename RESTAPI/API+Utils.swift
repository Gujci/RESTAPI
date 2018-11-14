//
//  API+Utils.swift
//  RESTAPI
//
//  Created by Gujgiczer Máté on 2017. 11. 05..
//  Copyright © 2017. gujci. All rights reserved.
//

extension APIError: Equatable {
    
    public static func ==(lhs: APIError, rhs: APIError) -> Bool {
        switch (rhs, lhs) {
        case let (.other(code1), .other(code2)):
            return code1 == code2
        case (.multipleChoice, .multipleChoice), (.badRequest, .badRequest),
             (.unouthorized, .unouthorized), (.forbidden, .forbidden),
             (.notFound, .notFound), (.methodNotAllowed, .methodNotAllowed),
             (.notAcceptable, .notAcceptable), (.requestTimeout, .requestTimeout),
             (.conflict, .conflict), (.serverError, .serverError),
             (.notImplemented, .notImplemented), (.gatewayTimeout, .gatewayTimeout):
            return true
        default:
            return false
        }
    }
}

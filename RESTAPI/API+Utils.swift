//
//  API+Utils.swift
//  RESTAPI
//
//  Created by Gujgiczer Máté on 2017. 11. 05..
//  Copyright © 2017. gujci. All rights reserved.
//

extension ResponseStatus: Equatable {
    
    public static func ==(lhs: ResponseStatus, rhs: ResponseStatus) -> Bool {
        switch (rhs, lhs) {
        case let (.other(code1), .other(code2)):
            return code1 == code2
        case (.none, .none), (.ok, .ok), (.created, .created), (.accepted, .accepted),
             (.noContent, .noContent), (.resetContent, .resetContent), (.partialContent, .partialContent),
             (.multipleChoice, .multipleChoice), (.badRequest, .badRequest),
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

extension ResponseStatus {
    
    public var isSuccess: Bool {
        switch self {
        case .ok, .created, .accepted, .noContent, .resetContent, .partialContent:
            return true
        case let .other(code) where 200...299 ~= code:
            return true
        default:
            return false
        }
    }
    
    public var isClientError: Bool {
        switch self {
        case .badRequest, .unouthorized, .forbidden, .notFound, .methodNotAllowed,
             .notAcceptable, .requestTimeout, .conflict:
            return true
        case let .other(code) where 400...499 ~= code:
            return true
        default:
            return false
        }
    }
    
    public var isServerError: Bool {
        switch self {
        case .notImplemented, .gatewayTimeout, .serverError:
            return true
        default:
            return false
        }
    }
}

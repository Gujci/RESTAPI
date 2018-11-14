//
//  API.swift
//
//  Created by Gujgiczer Máté on 19/03/16.
//

/// Protocol for request quer params
public protocol Queryable {
    func queryString(forKey key: String) -> [URLQueryItem]
}

public enum ContentType {
    case json
    case formEncoded
    case custom(String)
}

/// Converting to JSON error type
public enum ObjectParseError: Error {
    case jsonSerializeError
    case formencodeError
}

public protocol ValidRequestData {
    func type() -> ContentType
    func requestData() throws -> Data
}

/// Possibble response errors
public enum ResponseStatus: Error {
    case ok
    case created
    case accepted
    case noContent
    case resetContent
    case partialContent
    case multipleChoice
    case badRequest
    case unouthorized
    case forbidden
    case notFound
    case methodNotAllowed
    case notAcceptable
    case requestTimeout
    case conflict
    case serverError
    case notImplemented
    case gatewayTimeout
    case other(Int)
    
    init?(with response: URLResponse?) {
        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
            switch statusCode {
            case 200:
                self = .ok
            case 201:
                self = .created
            case 202:
                self = .accepted
            case 204:
                self = .noContent
            case 205:
                self = .resetContent
            case 206:
                self = .partialContent
            case 300:
                self = .multipleChoice
            case 400:
                self = .badRequest
            case 401:
                self = .unouthorized
            case 403:
                self = .forbidden
            case 404:
                self = .notFound
            case 405:
                self = .methodNotAllowed
            case 406:
                self = .notAcceptable
            case 408:
                self = .requestTimeout
            case 409:
                self = .conflict
            case 501:
                self = .notImplemented
                break
            case 504:
                self = .gatewayTimeout
                break
            case 500...599:
                self = .serverError
                break
            default:
                self = .other(statusCode)
            }
        }
        else {
            return nil
        }
    }
}

public protocol ValidResponseData {
    static func createInstance(from data: Data) throws -> Self
}

/// Possibble authentivation types for the request
public enum AuthenticationType {
    case none
    case httpHeader
    case urlParameter //a.k.a. Query
}

/// Authentication manager type
open class RequestAuthenticator {
    open var type: AuthenticationType = .none
    open var accessToken: String?
    open var tokenKey: String?
    
    public init() { }
    
    func authenticateURLRequest(_ req: URLRequest) -> URLRequest {
        var req = req
        switch self.type {
        case .httpHeader where accessToken != nil && tokenKey != nil:
            req.addValue(accessToken!,forHTTPHeaderField: tokenKey!)
            return req
        case .urlParameter where accessToken != nil && tokenKey != nil:
            req.url = URL(url: req.url!,query: [tokenKey!: accessToken!])
            return req
        default:
            return req
        }
    }
}

open class API {
    
    /// Authentication manager
    open var authentication: RequestAuthenticator
    /// Base url for the given instance
    open var baseURL: String
    /// Has any authentication
    open var hasSession: Bool {
        get {
            return authentication.accessToken != nil
        }
    }
    
    open var headers: [String: String] = {
       return [
        "Accept": "application/json",
        "Accept-Language": Bundle.main.preferredLocalizations.first ?? "en"
        ]
    }()
    
    /// Initializes an API instance
    /// - Params:
    ///     - baseUrl: Base server url of the instance
    ///     - authentication: Optional authentication manager for the instance
    public init(withBaseUrl baseUrl: String, authentication: RequestAuthenticator? = nil) {
        self.baseURL = baseUrl
        if let givenAuthentication = authentication {
            self.authentication = givenAuthentication
        }
        else {
            self.authentication = RequestAuthenticator()
        }
    }
    
    /// Performs a POST request to the given endpont
    /// - Params:
    ///     - endpoint: endpint of the server to perfor the request
    ///     - query: query parameters of the request, Values should be Queryable, Array and String types are Queryable by default.
    ///     - data: HTTP body paramter, must comform to ValidJSONObject protocol. Dictionaries and Arrays are ValidJSONObjects by default.
    ///     - completion: callback on return with error and data paramterst.
    public func post<T: ValidResponseData>(_ endpoint: String, query: [String: Queryable]? = nil, data: ValidRequestData? = nil,
                                           completion: @escaping ((_ status: ResponseStatus?, _ object: T?) -> ())) {
        parseableRequest("POST", endpoint: endpoint, query: query, data: data, completion: completion)
    }
    
    /// Performs a PUT request to the given endpont
    /// - Params:
    ///     - endpoint: endpint of the server to perfor the request
    ///     - query: query parameters of the request, Values should be Queryable, Array and String types are Queryable by default.
    ///     - data: HTTP body paramter, must comform to ValidJSONObject protocol. Dictionaries and Arrays are ValidJSONObjects by default.
    ///     - completion: callback on return with error and data paramterst.
    public func put<T: ValidResponseData>(_ endpoint: String, query: [String: Queryable]? = nil, data: ValidRequestData? = nil,
                                          completion: @escaping (_ status: ResponseStatus?, _ object: T?) -> ()) {
        parseableRequest("PUT", endpoint: endpoint, query: query, data: data, completion: completion)
    }
    
    /// Performs a GET request to the given endpont
    /// - Params:
    ///     - endpoint: endpint of the server to perfor the request
    ///     - query: query parameters of the request, Values should be Queryable, Array and String types are Queryable by default.
    ///     - data: HTTP body paramter, must comform to ValidJSONObject protocol. Dictionaries and Arrays are ValidJSONObjects by default.
    ///     - completion: callback on return with error and data paramterst.
    public func get<T: ValidResponseData>(_ endpoint: String, query: [String: Queryable]? = nil, data: ValidRequestData? = nil,
                                          completion: @escaping (_ status: ResponseStatus?, _ object: T?) -> ()) {
        parseableRequest("GET", endpoint: endpoint, query: query, data: data, completion: completion)
    }
    
    /// Performs a DELETE request to the given endpont
    /// - Params:
    ///     - endpoint: endpint of the server to perfor the request
    ///     - query: query parameters of the request, Values should be Queryable, Array and String types are Queryable by default.
    ///     - data: HTTP body paramter, must comform to ValidJSONObject protocol. Dictionaries and Arrays are ValidJSONObjects by default.
    ///     - completion: callback on return with error and data paramterst.
    public func delete<T: ValidResponseData>(_ endpoint: String, query: [String: Queryable]? = nil, data: ValidRequestData? = nil,
                                             completion: @escaping (_ status: ResponseStatus?, _ object: T?) -> ()) {
        parseableRequest("DELETE", endpoint: endpoint, query: query, data: data, completion: completion)
    }
    
    /// Performs a PATCH request to the given endpont
    /// - Params:
    ///     - endpoint: endpint of the server to perfor the request
    ///     - query: query parameters of the request, Values should be Queryable, Array and String types are Queryable by default.
    ///     - data: HTTP body paramter, must comform to ValidJSONObject protocol. Dictionaries and Arrays are ValidJSONObjects by default.
    ///     - completion: callback on return with error and data paramterst.
    public func patch<T: ValidResponseData>(_ endpoint: String, query: [String: Queryable]? = nil, data: ValidRequestData? = nil,
                                            completion: @escaping (_ status: ResponseStatus?, _ object: T?) -> ()) {
        parseableRequest("PATCH", endpoint: endpoint, query: query, data: data, completion: completion)
    }
}

/// Legacy support
@available(*, unavailable, renamed: "ResponseStatus")
public typealias APIError = ResponseStatus

public typealias ValidJSONObject = ValidJSONData

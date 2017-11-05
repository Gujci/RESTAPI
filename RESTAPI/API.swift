//
//  API.swift
//
//  Created by Gujgiczer Máté on 19/03/16.
//

import SwiftyJSON

/// Protocol for request quer params
public protocol Queryable {
    func queryString(forKey key: String) -> [URLQueryItem]
}

public enum ContentType {
    case json
    case formEncoded
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
public enum APIError: Error {
    case other(Int)
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
    //TODO: - expand
    
    init?(withResponse response: URLResponse?) {
        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
            switch statusCode {
            case 200...299:
                return nil
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
    open func post(_ endpoint: String, query: [String: Queryable]? = nil, data: ValidRequestData? = nil,
        completion: @escaping (_ error: APIError?, _ object: JSON?) -> ()) {
            dataTask(clientURLRequest(endpoint, query: query, params: data), method: "POST", completion: completion)
    }
    
    /// Performs a PUT request to the given endpont
    /// - Params:
    ///     - endpoint: endpint of the server to perfor the request
    ///     - query: query parameters of the request, Values should be Queryable, Array and String types are Queryable by default.
    ///     - data: HTTP body paramter, must comform to ValidJSONObject protocol. Dictionaries and Arrays are ValidJSONObjects by default.
    ///     - completion: callback on return with error and data paramterst.
    open func put(_ endpoint: String, query: [String: Queryable]? = nil, data: ValidRequestData? = nil,
        completion: @escaping (_ error: APIError?, _ object: JSON?) -> ()) {
            dataTask(clientURLRequest(endpoint, query: query, params: data), method: "PUT", completion: completion)
    }
    
    /// Performs a GET request to the given endpont
    /// - Params:
    ///     - endpoint: endpint of the server to perfor the request
    ///     - query: query parameters of the request, Values should be Queryable, Array and String types are Queryable by default.
    ///     - data: HTTP body paramter, must comform to ValidJSONObject protocol. Dictionaries and Arrays are ValidJSONObjects by default.
    ///     - completion: callback on return with error and data paramterst.
    open func get(_ endpoint: String, query: [String: Queryable]? = nil, data: ValidRequestData? = nil,
        completion: @escaping (_ error: APIError?, _ object: JSON?) -> ()) {
            dataTask(clientURLRequest(endpoint, query: query, params: data), method: "GET", completion: completion)
    }
    
    /// Performs a DELETE request to the given endpont
    /// - Params:
    ///     - endpoint: endpint of the server to perfor the request
    ///     - query: query parameters of the request, Values should be Queryable, Array and String types are Queryable by default.
    ///     - data: HTTP body paramter, must comform to ValidJSONObject protocol. Dictionaries and Arrays are ValidJSONObjects by default.
    ///     - completion: callback on return with error and data paramterst.
    open func delete(_ endpoint: String, query: [String: Queryable]? = nil, data: ValidRequestData? = nil,
        completion: @escaping (_ error: APIError?, _ object: JSON?) -> ()) {
            dataTask(clientURLRequest(endpoint, query: query, params: data), method: "DELETE", completion: completion)
    }
    
    open func patch(_ endpoint: String, query: [String: Queryable]? = nil, data: ValidRequestData? = nil,
                     completion: @escaping (_ error: APIError?, _ object: JSON?) -> ()) {
        dataTask(clientURLRequest(endpoint, query: query, params: data), method: "PATCH", completion: completion)
    }
}

//MARK: - Private part
fileprivate extension ContentType {
    
    var headerValue: String {
        switch self {
        case .json:
            return "application/json"
        case .formEncoded:
            return "application/x-www-form-urlencoded"
        }
    }
}

internal extension API {
    
    internal func dataTask(_ request: URLRequest, method: String, completion: @escaping (_ error: APIError?, _ object: JSON?) -> ()) {
        
        var request = request
        request.httpMethod = method
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        if ProcessInfo.processInfo.arguments.contains("APIRequestLoggingEnabled") {
            let loggedRequest = authentication.authenticateURLRequest(request)
            print("\n\(loggedRequest.httpMethod ?? "No http method") \(loggedRequest.url?.absoluteString ?? "No URL")")
            print("HEADERS:\n\(loggedRequest.allHTTPHeaderFields?.reduce("", { return $0 + "\t\($1.key): \($1.value)\n" }) ?? "No header fields")")
            if let body = loggedRequest.httpBody {
                print("BODY:\n\(String(data: body, encoding: .utf8) ?? "Cannot parse request body")")
            }
            else {
                print("Empty request body")
            }
        }
        session.dataTask(with: authentication.authenticateURLRequest(request) as URLRequest,
                         completionHandler: { (data, response, error) -> Void in
                            if let err = APIError(withResponse: response), ProcessInfo.processInfo.arguments.contains("APIErrorLoggingEnabled") {
                                switch (data, (data != nil ? try? JSON(data: data!) : nil)) {
                                case let (_, json) where json != .null:
                                    print("\(request.url?.absoluteString ?? "Unknown URL") \(err)\n \(json?.description ?? "No JSON")")
                                case let (data?, _) where String(data: data, encoding: .utf8) != nil:
                                    print("\(request.url?.absoluteString ?? "Unknown URL") \(err)\n \(String(data: data, encoding: .utf8)!)")
                                default:
                                    print("\(request.url?.absoluteString ?? "Unknown URL") \(err) with no description")
                                }
                            }
                            if let validData = data {
                                completion(APIError(withResponse: response), try? JSON(data: validData))
                            }
                            else {
                                completion(APIError(withResponse: response), nil)
                            }
                            
        }) .resume()
    }
    
    internal func clientURLRequest(_ path: String, query: [String: Queryable]?, params: ValidRequestData?)
        -> URLRequest {
            var request = URLRequest(url: URL(string: baseURL + path, query: query))
            if let params = params {
                let jsonData = try? params.requestData()
                request.httpBody = jsonData
            }
            
            headers.forEach() {
                request.addValue($0.1, forHTTPHeaderField: $0.0)
            }
            request.addValue((params?.type() ?? .json).headerValue, forHTTPHeaderField: "Content-Type")
            
            return request
    }
}

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

/// Possibble response errors
public enum APIError: Error {
    case unknown
    case notFound
    case unouthorized
    case forbidden
    case serverError
    case multipleChoice
    case badRequest
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
                break
            case 400:
                self = .badRequest
                break
            case 401:
                self = .unouthorized
                break
            case 403:
                self = .forbidden
                break
            case 404:
                self = .notFound
                break
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
                self = .unknown
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
        "Content-Type":"application/json",
        "Accept": "application/json",
        "Accept-Language": Bundle.main.preferredLocalizations.first ?? "en"
        ]
    }()
    
    /// Performs a POST request to the given endpont
    /// - Params:
    ///     - endpoint: endpint of the server to perfor the request
    ///     - query: query parameters of the request, Values should be Queryable, Array and String types are Queryable by default.
    ///     - data: HTTP body paramter, must comform to ValidJSONObject protocol. Dictionaries and Arrays are ValidJSONObjects by default.
    ///     - completion: callback on return with error and data paramterst.
    open func post(_ endpoint: String, query: [String: Queryable]? = nil, data: ValidJSONObject? = nil,
        completion: @escaping (_ error: APIError?, _ object: JSON?) -> ()) {
            dataTask(clientURLRequest(endpoint, query: query, params: data), method: "POST", completion: completion)
    }
    
    /// Performs a PUT request to the given endpont
    /// - Params:
    ///     - endpoint: endpint of the server to perfor the request
    ///     - query: query parameters of the request, Values should be Queryable, Array and String types are Queryable by default.
    ///     - data: HTTP body paramter, must comform to ValidJSONObject protocol. Dictionaries and Arrays are ValidJSONObjects by default.
    ///     - completion: callback on return with error and data paramterst.
    open func put(_ endpoint: String, query: [String: Queryable]? = nil, data: ValidJSONObject? = nil,
        completion: @escaping (_ error: APIError?, _ object: JSON?) -> ()) {
            dataTask(clientURLRequest(endpoint, query: query, params: data), method: "PUT", completion: completion)
    }
    
    /// Performs a GET request to the given endpont
    /// - Params:
    ///     - endpoint: endpint of the server to perfor the request
    ///     - query: query parameters of the request, Values should be Queryable, Array and String types are Queryable by default.
    ///     - data: HTTP body paramter, must comform to ValidJSONObject protocol. Dictionaries and Arrays are ValidJSONObjects by default.
    ///     - completion: callback on return with error and data paramterst.
    open func get(_ endpoint: String, query: [String: Queryable]? = nil, data: ValidJSONObject? = nil,
        completion: @escaping (_ error: APIError?, _ object: JSON?) -> ()) {
            dataTask(clientURLRequest(endpoint, query: query, params: data), method: "GET", completion: completion)
    }
    
    /// Performs a DELETE request to the given endpont
    /// - Params:
    ///     - endpoint: endpint of the server to perfor the request
    ///     - query: query parameters of the request, Values should be Queryable, Array and String types are Queryable by default.
    ///     - data: HTTP body paramter, must comform to ValidJSONObject protocol. Dictionaries and Arrays are ValidJSONObjects by default.
    ///     - completion: callback on return with error and data paramterst.
    open func delete(_ endpoint: String, query: [String: Queryable]? = nil, data: ValidJSONObject? = nil,
        completion: @escaping (_ error: APIError?, _ object: JSON?) -> ()) {
            dataTask(clientURLRequest(endpoint, query: query, params: data), method: "DELETE", completion: completion)
    }
    
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
    
    //MARK: - Private part
    
    internal func dataTask(_ request: URLRequest, method: String, completion: @escaping (_ error: APIError?, _ object: JSON?) -> ()) {
        
        var request = request
        request.httpMethod = method
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: authentication.authenticateURLRequest(request) as URLRequest,
                         completionHandler: { (data, response, error) -> Void in
            if let validData = data {
                completion(APIError(withResponse: response), JSON(data: validData))
            }
            else {
                completion(APIError(withResponse: response), nil)
            }
            
        }) .resume()
    }
    
    internal func clientURLRequest(_ path: String, query: [String: Queryable]?, params: ValidJSONObject?)
        -> URLRequest {
            var request = URLRequest(url: URL(string: baseURL + path, query: query))
            if let params = params {
                let jsonData = try? params.JSONFormat()
                request.httpBody = jsonData
            }
            
            headers.forEach() {
                request.addValue($0.1, forHTTPHeaderField: $0.0)
            }
        
            return request
    }
}

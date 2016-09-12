//
//  API.swift
//
//  Created by Gujgiczer Máté on 19/03/16.
//

import Foundation
import SwiftyJSON

/// Protocol for request quer params
public protocol Queryable {
    func queryString(forKey key: String) -> [NSURLQueryItem]
}

/// Possibble response errors
public enum APIError: Int, ErrorType {
    case Unknown
    case NotFound
    case Unouthorized
    case Forbidden
    case ServerError
    case MultipleChoice
    case BadRequest
    //TODO: - expand
    
    init?(withResponse response: NSURLResponse?) {
        if let statusCode = (response as? NSHTTPURLResponse)?.statusCode {
            switch statusCode {
            case 200...299:
                return nil
            case 300:
                self = .MultipleChoice
            case 400:
                self = .BadRequest
            case 401:
                self = .Unouthorized
            case 403:
                self = .Forbidden
            case 404:
                self = .NotFound
            case 500...599:
                self = .ServerError
            default:
                self = .Unknown
            }
        }
        else {
            return nil
        }
    }
}

/// Possibble authentivation types for the request
public enum AuthenticationType {
    case None
    case HTTPHeader
    case URLParameter //a.k.a. Query
}

/// Authentication manager type
public class RequestAuthenticator {
    public var type: AuthenticationType = .None
    public var accessToken: String?
    public var tokenKey: String?
    
    public init() { }
    
    func authenticateURLRequest(req: NSMutableURLRequest) -> NSMutableURLRequest {
        switch self.type {
        case .HTTPHeader where accessToken != nil && tokenKey != nil:
            req.addValue(accessToken!,forHTTPHeaderField: tokenKey!)
            return req
        case .URLParameter where accessToken != nil && tokenKey != nil:
            req.URL = NSURL(url: req.URL!,query: [tokenKey!: accessToken!])
            return req
        default:
            return req
        }
    }
}

public class API {
    
    /// Authentication manager
    public var authentication: RequestAuthenticator
    /// Base url for the given instance
    public var baseURL: String
    /// Has any authentication
    public var hasSession: Bool {
        get {
            return authentication.accessToken != nil
        }
    }
    
    public var headers: [String: String] = {
       return [
        "Content-Type":"application/json",
        "Accept": "application/json",
        "Accept-Language": NSBundle.mainBundle().preferredLocalizations.first ?? "en"
        ]
    }()
    
    /// Performs a POST request to the given endpont
    /// - Params:
    ///     - endpoint: endpint of the server to perfor the request
    ///     - query: query parameters of the request, Values should be Queryable, Array and String types are Queryable by default.
    ///     - data: HTTP body paramter, must comform to ValidJSONObject protocol. Dictionaries and Arrays are ValidJSONObjects by default.
    ///     - completion: callback on return with error and data paramterst.
    public func post(endpoint: String, query: [String: Queryable]? = nil, data: ValidJSONObject? = nil,
        completion: (error: APIError?, object: JSON?) -> ()) {
            dataTask(clientURLRequest(endpoint, query: query, params: data), method: "POST", completion: completion)
    }
    
    /// Performs a PUT request to the given endpont
    /// - Params:
    ///     - endpoint: endpint of the server to perfor the request
    ///     - query: query parameters of the request, Values should be Queryable, Array and String types are Queryable by default.
    ///     - data: HTTP body paramter, must comform to ValidJSONObject protocol. Dictionaries and Arrays are ValidJSONObjects by default.
    ///     - completion: callback on return with error and data paramterst.
    public func put(endpoint: String, query: [String: Queryable]? = nil, data: ValidJSONObject? = nil,
        completion: (error: APIError?, object: JSON?) -> ()) {
            dataTask(clientURLRequest(endpoint, query: query, params: data), method: "PUT", completion: completion)
    }
    
    /// Performs a GET request to the given endpont
    /// - Params:
    ///     - endpoint: endpint of the server to perfor the request
    ///     - query: query parameters of the request, Values should be Queryable, Array and String types are Queryable by default.
    ///     - data: HTTP body paramter, must comform to ValidJSONObject protocol. Dictionaries and Arrays are ValidJSONObjects by default.
    ///     - completion: callback on return with error and data paramterst.
    public func get(endpoint: String, query: [String: Queryable]? = nil, data: ValidJSONObject? = nil,
        completion: (error: APIError?, object: JSON?) -> ()) {
            dataTask(clientURLRequest(endpoint, query: query, params: data), method: "GET", completion: completion)
    }
    
    /// Performs a DELETE request to the given endpont
    /// - Params:
    ///     - endpoint: endpint of the server to perfor the request
    ///     - query: query parameters of the request, Values should be Queryable, Array and String types are Queryable by default.
    ///     - data: HTTP body paramter, must comform to ValidJSONObject protocol. Dictionaries and Arrays are ValidJSONObjects by default.
    ///     - completion: callback on return with error and data paramterst.
    public func delete(endpoint: String, query: [String: Queryable]? = nil, data: ValidJSONObject? = nil,
        completion: (error: APIError?, object: JSON?) -> ()) {
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
    
    internal func dataTask(request: NSMutableURLRequest, method: String, completion: (error: APIError?, object: JSON?) -> ()) {
        request.HTTPMethod = method
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        session.dataTaskWithRequest(authentication.authenticateURLRequest(request)) { (data, response, error) -> Void in
            if let validData = data {
                completion(error: APIError(withResponse: response), object: JSON(data: validData))
            }
            else {
                completion(error: APIError(withResponse: response), object: nil)
            }
            
        }.resume()
    }
    
    internal func clientURLRequest(path: String, query: [String: Queryable]?, params: ValidJSONObject?)
        -> NSMutableURLRequest {
            let request = NSMutableURLRequest(URL: NSURL(string: baseURL + path, query: query))
            if let params = params {
                let jsonData = try? params.JSONFormat()
                request.HTTPBody = jsonData
            }
            
            headers.forEach() {
                request.addValue($0.1, forHTTPHeaderField: $0.0)
            }
        
            return request
    }
}
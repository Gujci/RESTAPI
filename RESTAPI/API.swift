//
//  API.swift
//
//  Created by Gujgiczer Máté on 19/03/16.
//

import Foundation
import SwiftyJSON

//TODO: - documentation

public protocol Queryable {
    func queryString(forKey key: String) -> [NSURLQueryItem]
}

public protocol JSONParseable {
    init(withJSON data:JSON)
}

public protocol ValidJSONObject {
    func JSONFormat() throws -> NSData
}

//TODO: use this type for body params
public protocol JSONConvertible {
    associatedtype T: ValidJSONObject
    var parameterValue: T {get}
}

public enum ValidJSONObjectParseError: ErrorType {
    case JSONSerializeError
}

public enum APIError: Int, ErrorType {
    case Unknown
    case NotFound
    case Unouthorized
    case Forbidden
    case Timeout
    case MultipleChoice
    case BadRequest
    
    init?(withResponse response: NSURLResponse?) {
        if let statusCode = (response as? NSHTTPURLResponse)?.statusCode {
            switch statusCode {
            case 200:
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
                self = .Timeout
            default:
                self = .Unknown
            }
        }
        else {
            return nil
        }
    }
}

public enum AuthenticationType {
    case None
    case HTTPHeader
    case URLParameter //a.k.a. Query
}

public class RequestAuthenticator {
    public var type: AuthenticationType = .None
    public var accessToken: String?
    public var tokenKey: String?
    
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

//TODO: - data could be JSONConvertible as well

public class API {
    public var authentication: RequestAuthenticator
    public var baseURL: String
    
    public var hasSession: Bool {
        get {
            return authentication.accessToken != nil
        }
    }
    
    public func post(endpoint: String, query: Dictionary<String, Queryable>? = nil, data: ValidJSONObject? = nil,
        completion: (error: APIError?, object: JSON?) -> ()) {
            dataTask(clientURLRequest(endpoint, query: query, params: data), method: "POST", completion: completion)
    }
    
    public func put(endpoint: String, query: Dictionary<String, Queryable>? = nil, data: ValidJSONObject? = nil,
        completion: (error: APIError?, object: JSON?) -> ()) {
            dataTask(clientURLRequest(endpoint, query: query, params: data), method: "PUT", completion: completion)
    }
    
    public func get(endpoint: String, query: Dictionary<String, Queryable>? = nil, data: ValidJSONObject? = nil,
        completion: (error: APIError?, object: JSON?) -> ()) {
            dataTask(clientURLRequest(endpoint, query: query, params: data), method: "GET", completion: completion)
    }
    
    public func delete(endpoint: String, query: Dictionary<String, Queryable>? = nil, data: ValidJSONObject? = nil,
        completion: (error: APIError?, object: JSON?) -> ()) {
            dataTask(clientURLRequest(endpoint, query: query, params: data), method: "DELETE", completion: completion)
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
    
    internal func clientURLRequest(path: String,query: Dictionary<String, Queryable>?, params: ValidJSONObject?)
        -> NSMutableURLRequest {
            let request = NSMutableURLRequest(URL: NSURL(string: baseURL + path, query: query))
            if let params = params {
                let jsonData = try? params.JSONFormat()
                request.HTTPBody = jsonData
            }
            request.addValue("application/json",forHTTPHeaderField: "Content-Type")
            request.addValue("application/json",forHTTPHeaderField: "Accept")
            request.addValue(NSBundle.mainBundle().preferredLocalizations.first ?? "en",forHTTPHeaderField: "Accept-Language")
        
        return request
    }
    
    public init(withBaseUrl baseUrl: String, authentication: RequestAuthenticator? = nil) {
        self.baseURL = baseUrl
        if let givenAuthentication = authentication {
            self.authentication = givenAuthentication
        }
        else {
            self.authentication = RequestAuthenticator()
        }
    }
}
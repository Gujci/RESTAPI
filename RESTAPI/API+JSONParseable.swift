//
//  API+JSONParseable.swift
//
//  Created by Gujgiczer Máté on 23/03/16.
//

import SwiftyJSON

/// Protocol for parseable response objects
public protocol JSONParseable {
    init(withJSON data:JSON)
}

//TODO: - make JSON and [JSON] comform to JSONParseable to reduce redundant code
public extension API {
    
    public func post<T: JSONParseable>(_ endpoint: String, query: [String: Queryable]? = nil, data: ValidJSONObject? = nil,
              completion: @escaping ((_ error: APIError?, _ object: T?) -> ())) {
        parseableRequest("POST", endpoint: endpoint, query: query, data: data, completion: completion)
    }
    
    public func put<T: JSONParseable>(_ endpoint: String, query: [String: Queryable]? = nil, data: ValidJSONObject? = nil,
             completion: @escaping (_ error: APIError?, _ object: T?) -> ()) {
        parseableRequest("PUT", endpoint: endpoint, query: query, data: data, completion: completion)
    }
    
    public func get<T: JSONParseable>(_ endpoint: String, query: [String: Queryable]? = nil, data: ValidJSONObject? = nil,
             completion: @escaping (_ error: APIError?, _ object: T?) -> ()) {
        parseableRequest("GET", endpoint: endpoint, query: query, data: data, completion: completion)
    }
    
    public func delete<T: JSONParseable>(_ endpoint: String, query: [String: Queryable]? = nil, data: ValidJSONObject? = nil,
                completion: @escaping (_ error: APIError?, _ object: T?) -> ()) {
        parseableRequest("DELETE", endpoint: endpoint, query: query, data: data, completion: completion)
    }
    
    public func post<T: JSONParseable>(_ endpoint: String, query: [String: Queryable]? = nil, data: ValidJSONObject? = nil,
              completion: @escaping ((_ error: APIError?, _ object: [T]?) -> ())) {
        parseableRequest("POST", endpoint: endpoint, query: query, data: data, completion: completion)
    }
    
    public func put<T: JSONParseable>(_ endpoint: String, query: [String: Queryable]? = nil, data: ValidJSONObject? = nil,
             completion: @escaping (_ error: APIError?, _ object: [T]?) -> ()) {
        parseableRequest("PUT", endpoint: endpoint, query: query, data: data, completion: completion)
    }
    
    public func get<T: JSONParseable>(_ endpoint: String, query: [String: Queryable]? = nil, data: ValidJSONObject? = nil,
             completion: @escaping (_ error: APIError?, _ object: [T]?) -> ()) {
        parseableRequest("GET", endpoint: endpoint, query: query, data: data, completion: completion)
    }
    
    public func delete<T: JSONParseable>(_ endpoint: String, query: [String: Queryable]? = nil, data: ValidJSONObject? = nil,
                completion: @escaping (_ error: APIError?, _ object: [T]?) -> ()) {
        parseableRequest("DELETE", endpoint: endpoint, query: query, data: data, completion: completion)
    }
    
    //MARK: - Private part
    
    fileprivate func parseableRequest<T: JSONParseable>(_ method: String, endpoint: String, query: [String: Queryable]? = nil,
                                   data: ValidJSONObject? = nil,
                                   completion: @escaping (_ error: APIError?, _ object: T?) -> ()) {
        dataTask(clientURLRequest(endpoint, query: query, params: data), method: method) { err ,data in
            if let validData = data {
                completion(err, T(withJSON: validData))
            }
            else {
                completion(err, nil)
            }
        }
    }
    
    fileprivate func parseableRequest<T: JSONParseable>(_ method: String, endpoint: String, query: [String: Queryable]? = nil,
                                  data: ValidJSONObject? = nil,
                                  completion: @escaping (_ error: APIError?, _ object: [T]?) -> ()) {
        dataTask(clientURLRequest(endpoint, query: query, params: data), method: method) { err ,data in
            if let arrayData = data?.array {
                let JSONData = arrayData.map() {element in
                    return T(withJSON: element)
                }
                completion(err, JSONData)
            }
            else {
                completion(err, nil)
            }
        }
    }
}

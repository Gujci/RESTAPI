//
//  API+JSONParseable.swift
//
//  Created by Gujgiczer Máté on 23/03/16.
//

import Foundation
import SwiftyJSON

/// Protocol for parseable response objects
public protocol JSONParseable {
    init(withJSON data:JSON)
}

//TODO: - remove duplicates & document it
public extension API {
    
    public func post<T: JSONParseable>(endpoint: String, query: Dictionary<String, Queryable>? = nil, data: ValidJSONObject? = nil,
              completion: ((error: APIError?, object: T?) -> ())) {
        parseableRequest("POST", endpoint: endpoint, query: query, data: data, completion: completion)
    }
    
    public func put<T: JSONParseable>(endpoint: String, query: Dictionary<String, Queryable>? = nil, data: ValidJSONObject? = nil,
             completion: (error: APIError?, object: T?) -> ()) {
        parseableRequest("PUT", endpoint: endpoint, query: query, data: data, completion: completion)
    }
    
    public func get<T: JSONParseable>(endpoint: String, query: Dictionary<String, Queryable>? = nil, data: ValidJSONObject? = nil,
             completion: (error: APIError?, object: T?) -> ()) {
        parseableRequest("GET", endpoint: endpoint, query: query, data: data, completion: completion)
    }
    
    public func delete<T: JSONParseable>(endpoint: String, query: Dictionary<String, Queryable>? = nil, data: ValidJSONObject? = nil,
                completion: (error: APIError?, object: T?) -> ()) {
        parseableRequest("DELETE", endpoint: endpoint, query: query, data: data, completion: completion)
    }
    
    public func post<T: JSONParseable>(endpoint: String, query: Dictionary<String, Queryable>? = nil, data: ValidJSONObject? = nil,
              completion: ((error: APIError?, object: [T]?) -> ())) {
        parseableRequest("POST", endpoint: endpoint, query: query, data: data, completion: completion)
    }
    
    public func put<T: JSONParseable>(endpoint: String, query: Dictionary<String, Queryable>? = nil, data: ValidJSONObject? = nil,
             completion: (error: APIError?, object: [T]?) -> ()) {
        parseableRequest("PUT", endpoint: endpoint, query: query, data: data, completion: completion)
    }
    
    public func get<T: JSONParseable>(endpoint: String, query: Dictionary<String, Queryable>? = nil, data: ValidJSONObject? = nil,
             completion: (error: APIError?, object: [T]?) -> ()) {
        parseableRequest("GET", endpoint: endpoint, query: query, data: data, completion: completion)
    }
    
    public func delete<T: JSONParseable>(endpoint: String, query: Dictionary<String, Queryable>? = nil, data: ValidJSONObject? = nil,
                completion: (error: APIError?, object: [T]?) -> ()) {
        parseableRequest("DELETE", endpoint: endpoint, query: query, data: data, completion: completion)
    }
    
    //MARK: - Private part
    
    private func parseableRequest<T: JSONParseable>(method: String, endpoint: String, query: Dictionary<String, Queryable>? = nil,
                                   data: ValidJSONObject? = nil,
                                   completion: (error: APIError?, object: T?) -> ()) {
        dataTask(clientURLRequest(endpoint, query: query, params: data), method: method) { err ,data in
            if let validData = data {
                completion(error: err, object: T(withJSON: validData))
            }
            else {
                completion(error: err, object: nil)
            }
        }
    }
    
    private func parseableRequest<T: JSONParseable>(method: String, endpoint: String, query: Dictionary<String, Queryable>? = nil,
                                  data: ValidJSONObject? = nil,
                                  completion: (error: APIError?, object: [T]?) -> ()) {
        dataTask(clientURLRequest(endpoint, query: query, params: data), method: method) { err ,data in
            if let arrayData = data?.array {
                let JSONData = arrayData.map() {element in
                    return T(withJSON: element)
                }
                completion(error: err, object: JSONData)
            }
            else {
                completion(error: err, object: nil)
            }
        }
    }
}
//
//  APIImplementation.swift
//  RESTAPI iOS
//
//  Created by Gujgiczer Máté on 2018. 11. 09..
//  Copyright © 2018. gujci. All rights reserved.
//

import Foundation
import SwiftyJSON

//MARK: - Private part
internal extension ContentType {
    
    var headerValue: String {
        switch self {
        case .json:
            return "application/json"
        case .formEncoded:
            return "application/x-www-form-urlencoded"
        case let .custom(format):
            return format
        }
    }
}

internal extension API {
    
    func parseableRequest<T: ValidResponseData>(_ method: String, endpoint: String, query: [String: Queryable]? = nil,
                                                         data: ValidRequestData? = nil,
                                                         completion: @escaping (_ status: ResponseStatus, _ object: T?) -> ()) {
        dataTask(clientURLRequest(endpoint, query: query, params: data), method: method) { status ,data in
            if let validData = data  {
                completion(status, try? T.createInstance(from: validData))
            }
            else {
                completion(status, nil)
            }
        }
    }
    
    func dataTask(_ request: URLRequest, method: String, completion: @escaping (_ status: ResponseStatus, _ object: Data?) -> ()) {
        
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
                            let responseStatus = ResponseStatus(with: response)
                            if !responseStatus.isSuccess, ProcessInfo.processInfo.arguments.contains("APIErrorLoggingEnabled") {
                                switch (data, (data != nil ? try? JSON(data: data!) : nil)) {
                                case let (_, json) where json != .null:
                                    print("\(request.url?.absoluteString ?? "Unknown URL") \(responseStatus)\n \(json?.description ?? "No JSON")")
                                case let (data?, _) where String(data: data, encoding: .utf8) != nil:
                                    print("\(request.url?.absoluteString ?? "Unknown URL") \(responseStatus)\n \(String(data: data, encoding: .utf8)!)")
                                default:
                                    print("\(request.url?.absoluteString ?? "Unknown URL") \(responseStatus) with no description")
                                }
                            }
                            completion(responseStatus, data)
                            
        }) .resume()
    }
    
    func clientURLRequest(_ path: String, query: [String: Queryable]?, params: ValidRequestData?)
        -> URLRequest {
            var request = URLRequest(url: URL(string: baseURL + path, query: query))
            if let params = params, let httpData = try? params.requestData() {
                request.httpBody = httpData
                request.addValue(String(httpData.count), forHTTPHeaderField: "Content-Length")
            }
            
            headers.forEach() {
                request.addValue($0.1, forHTTPHeaderField: $0.0)
            }
            request.addValue((params?.type() ?? .json).headerValue, forHTTPHeaderField: "Content-Type")
            
            return request
    }
}

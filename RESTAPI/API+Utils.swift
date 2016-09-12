//
//  API+Utils.swift
//
//  Created by Gujgiczer Máté on 23/03/16.
//

import Foundation
import SwiftyJSON

extension Array: Queryable {
    public func queryString(forKey key: String) -> [NSURLQueryItem] {
        return self.map() { item in
            return NSURLQueryItem(name: "\(key)[]", value: "\(item)")
        }
    }
}

extension String: Queryable {
    public func queryString(forKey key: String) -> [NSURLQueryItem] {
        return [NSURLQueryItem(name: key, value: self)]
    }
}

extension NSURL {
    convenience init(string: String, query: Dictionary<String, Queryable>?) {
        if query == nil {
            self.init(string: string)!
            return
        }
        let components = NSURLComponents(string: string)
        var querryItems = components?.queryItems ?? Array<NSURLQueryItem>()
        query?.forEach() {
            querryItems.appendContentsOf($0.1.queryString(forKey: $0.0))
        }
        components?.queryItems = querryItems
        self.init(string: "",relativeToURL: components!.URL)!
    }
    
    convenience init(url: NSURL, query: Dictionary<String, Queryable>?) {
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
        var querryItems = components?.queryItems ?? Array<NSURLQueryItem>()
        query?.forEach() {
            querryItems.appendContentsOf($0.1.queryString(forKey: $0.0))
        }
        components?.queryItems = querryItems
        self.init(string: "",relativeToURL: components!.URL)!
    }
}

extension NSDate {
    static var timestamp: Double {
        get {
            return NSDate().timeIntervalSince1970 * 1000
        }
    }
}

func + <K, V>(left: Dictionary<K, V>, right: Dictionary<K, V>) -> Dictionary<K, V> {
    var map = Dictionary<K, V>()
    
    for (k, v) in left {
        map[k] = v
    }
    
    for (k, v) in right {
        map[k] = v
    }
    
    return map
}

func += <K, V> (inout left: Dictionary<K, V>, right: Dictionary<K, V>) -> Dictionary<K, V> {
    for (k, v) in right {
        left[k] = v
    }
    
    return left
}
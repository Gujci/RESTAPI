//
//  API+Utils.swift
//
//  Created by Gujgiczer Máté on 23/03/16.
//

extension Array: Queryable {
    public func queryString(forKey key: String) -> [URLQueryItem] {
        return self.map() { item in
            return URLQueryItem(name: "\(key)[]", value: "\(item)")
        }
    }
}

extension String: Queryable {
    public func queryString(forKey key: String) -> [URLQueryItem] {
        return [URLQueryItem(name: key, value: self)]
    }
}

extension URL {
    init(string: String, query: Dictionary<String, Queryable>?) {
        if query == nil {
            self.init(string: string)!
            return
        }
        var components = URLComponents(string: string)
        var querryItems = components?.queryItems ?? Array<URLQueryItem>()
        query?.forEach() {
            querryItems.append(contentsOf: $0.value.queryString(forKey: $0.0))
        }
        components?.queryItems = querryItems
        self.init(string: components!.url!.absoluteString)!
    }
    
    init(url: URL, query: Dictionary<String, Queryable>?) {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var querryItems = components?.queryItems ?? Array<URLQueryItem>()
        query?.forEach() {
            querryItems.append(contentsOf: $0.1.queryString(forKey: $0.0))
        }
        components?.queryItems = querryItems
        self.init(string: components!.url!.absoluteString)!
    }
}

extension Date {
    static var timestamp: Double {
        get {
            return Date().timeIntervalSince1970 * 1000
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

func += <K, V> (left: inout Dictionary<K, V>, right: Dictionary<K, V>) -> Dictionary<K, V> {
    for (k, v) in right {
        left[k] = v
    }
    
    return left
}

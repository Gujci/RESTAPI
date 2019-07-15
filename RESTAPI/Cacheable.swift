//
//  Cacheable.swift
//
//  Created by Gujgiczer Mate on 2019. 07. 08..
//

import Foundation

// MARK: - Cachable protocol
public protocol Cachable: ValidResponseData {
    /// Static function which should return a cached instance found on a given key
    /// - Parameter for: uniquly identifies a request
    static func getPersistantData(for url: String) throws -> Self?
    /// Tells an instance to save itself to a persistent store
    /// - Parameter for: identifier on which the resource may be referenced later
    func savePersistant(for url: String) throws
}

// MARK: - CachePolicy for API
public enum CachePolicy {
    /// Denys cache, loads all data
    case noCache
    /// If founds it in cache returns it and stops
    case acceptCache
    /// If founds it in cache returns the it than refreshes the cache
    case refreshCache
    /// Returns tha cached data if ound furst, than returns the downloaded
    case newest
}

// MARK: RESTAPI load extension
extension API {
    /// This function will load the given resource like a `GET` request, applying the headers and given authentication.
    /// The plus, which it gives. is the caching mechanism. The response to the URL will be cached in the file fys, wich means the
    /// - Parameter url: source of the resource
    /// - Parameter cachePolicy: decides how to handle stored data
    /// - Parameter completion: callback with the parsed data, might get called several times based on the caching policy
    public func load<T: Cachable>(from url: String, cachePolicy: CachePolicy = .newest, completion: @escaping (_ data: T?) -> Void) {
        var foundInCache = false
        
        if let cachedData = try? T.getPersistantData(for: url) , cachePolicy != .noCache {
            foundInCache = true
            completion(cachedData)
        }
        
        if cachePolicy == .acceptCache && foundInCache {
            return
        }
        
        get(url) { (_, instance: T?) in
            if cachePolicy != .noCache {
                try? instance?.savePersistant(for: url)
            }
            completion(instance)
        }
    }
}

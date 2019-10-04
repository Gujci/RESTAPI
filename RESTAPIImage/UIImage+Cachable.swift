//
//  File.swift
//  
//
//  Created by Gujgiczer Mate on 2019. 07. 08..
//

import RESTAPI
#if canImport(UIKit)
import UIKit

// MARK: - Error type
public enum UIImageInitializeError: Error {
    case failed
}

// MARK: - UIImage conformance
extension UIImage: ValidResponseData {
    
    public static func createInstance(from data: Data) throws -> Self {
        guard let image = UIImage(data: data) as? Self else { throw UIImageInitializeError.failed }
        return image
    }
}

extension UIImage: Cachable {
    
    private static var cacheURL: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    public func savePersistant(for url: String) throws {
        let cacheUrl = UIImage.cacheURL.appendingPathComponent(url.components(separatedBy: "/").last!)
        
        try pngData()?.write(to: cacheUrl, options: .atomicWrite)
    }
    
    public static func getPersistantData(for url: String) throws -> Self? {
        let cacheUrl = cacheURL.appendingPathComponent(url.components(separatedBy: "/").last!)
        let data = try Data(contentsOf: cacheUrl, options: .mappedIfSafe)
        return UIImage(data: data) as? Self
    }
}
#endif

#if os(tvOS) && os(iOS)
// MARK: UIImageView extension
public extension UIImageView {
    
    private static let loader = API(withBaseUrl: "")
    
    private struct Holder {
        static var _imageURL: String?
    }
    
    var imageUrl: String? {
        get {
            return Holder._imageURL
        }
        set {
            Holder._imageURL = newValue
            guard let url = newValue else { return }
            UIImageView.loader.load(from: url, cachePolicy: .refreshCache) { [weak self] (image) in
                DispatchQueue.main.async { self?.image = image }
            }
        }
    }
}
#endif

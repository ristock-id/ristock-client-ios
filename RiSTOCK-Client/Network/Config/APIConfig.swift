//
//  APIConfig.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 19/10/25.
//

import Foundation

enum APIConfig {
    static let baseURL: String = {
        guard let baseString = Secrets.shared.string(forKey: "API_BASE_URL"),
              let apiVersion = Secrets.shared.string(forKey: "API_VERSION"),
              !baseString.isEmpty,
              !apiVersion.isEmpty else {
            
            fatalError("[ERROR] API_BASE_URL or API_VERSION missing from Secrets.plist")
        }
        
        guard let baseURL = URL(string: baseString) else {
            fatalError("[ERROR] API_BASE_URL in Secrets.plist is not a valid URL: \(baseString)")
        }
        
        let versionedURL = baseURL.appendingPathComponent(apiVersion)
        
        // TODO: Refactor this to Return URL instead of String
        if !versionedURL.absoluteString.hasSuffix("/") {
            return versionedURL.appendingPathComponent("") .absoluteString
        } else {
            return versionedURL.absoluteString
        }
    }()
}

protocol EndpointProtocol {
    var path: String { get }
    var urlString: String { get }
    var url: URL? { get }
}

extension EndpointProtocol {
    var urlString: String {
        return APIConfig.baseURL + path
    }
    
    var url: URL? {
        return URL(string: urlString)
    }
}

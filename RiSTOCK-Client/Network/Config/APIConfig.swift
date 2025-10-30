//
//  APIConfig.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 19/10/25.
//

import Foundation

enum APIConfig {
//    static let baseURL = "https://keely-checkable-unhedonistically.ngrok-free.dev/v1"
    static let baseURL = "http://127.0.0.1:5000/v1"
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

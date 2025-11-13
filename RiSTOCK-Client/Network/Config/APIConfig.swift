//
//  APIConfig.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 19/10/25.
//

import Foundation

enum APIConfig {
    static let baseURL = "https://ristock-be-main-jszuzedd7a-et.a.run.app/v1"
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

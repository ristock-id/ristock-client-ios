//
//  FileEndpoint.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 21/10/25.
//

import Foundation

enum FileEndpoint: EndpointProtocol {
    case upload
    
    var path: String {
        switch self {
        case .upload:
            return "/upload"
        }
    }
}

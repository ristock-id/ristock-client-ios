//
//  PipelineEndpoint.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 21/10/25.
//

import Foundation

enum PipelineEndpoint: EndpointProtocol {
    case get
    case updateStatusStock
    
    var path: String {
        switch self {
        case .get:
//            return "/pipelines"
            return "/most-recently-updated"
        case .updateStatusStock:
            return "/bulk-update-restock-status"
        }
    }
}

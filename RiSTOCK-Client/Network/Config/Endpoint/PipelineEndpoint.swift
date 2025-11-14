//
//  PipelineEndpoint.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 21/10/25.
//

import Foundation

enum PipelineEndpoint: EndpointProtocol {
    case get
    case triggerPipeline
    case updateStatusStock
    case getCheckRecommendationSummary
    
    case getProductsSummary
    case getProductDetail
    
    var path: String {
        switch self {
        case .get:
            return "/most-recently-updated"
        case .getCheckRecommendationSummary:
            return "/check-recommendation-summary"
        case .triggerPipeline:
            return "/pipelines"
        case .updateStatusStock:
            return "/bulk-update-restock-status"
        case .getProductsSummary:
            return "/recent-updated/summary"
        case .getProductDetail:
            return "/recent-updated/detail"
        }
    }
}

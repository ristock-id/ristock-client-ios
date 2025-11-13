//
//  ProductInsightPaginationResponse.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 12/11/25.
//

import Foundation

struct ProductInsightPaginationResponse: JSONDecodable {
    let items: [ProductInsightResponse]
    let total: Int
    let page: Int
    let pageSize: Int
    let totalPages: Int
    let minUpdatedAt: String?
    let maxUpdatedAt: String?
    let summary: Summary?
    
    enum CodingKeys: String, CodingKey {
        case items
        case total
        case page
        case pageSize = "page_size"
        case totalPages = "total_pages"
        case minUpdatedAt = "min_updated_at"
        case maxUpdatedAt = "max_updated_at"
        case summary
    }
}

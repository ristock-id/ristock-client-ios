//
//  ProductSummaryResponse.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 13/11/25.
//

import Foundation

// MARK: - UI Model
struct ProductSummaryUI: Identifiable, Equatable {
    let id: String
    var index: Int = -1
    var name: String
    var checkRecommendation: CheckRecommendationStatus
    var stockStatus: StockStatus?
    var updatedAt: Date?
    var analysisUpdatedAt: Date?
    var isRestockStatusExpired: Bool {
        guard let updatedAt = updatedAt, let analysisUpdatedAt = analysisUpdatedAt else {
            return false
        }
        return updatedAt < analysisUpdatedAt
    }
    
    // This is new attribute after version DEV-161
    var rop: Int?
    var stockAmount: Int?
    
    /// This is mock data for testing purposes or UI previews.
    static let mockData = ProductSummaryUI(
        id: "prod_001",
        index: 0,
        name: "Sample Product",
        checkRecommendation: .now,
        stockStatus: .low,
        updatedAt: Date(),
        analysisUpdatedAt: Date().addingTimeInterval(-86400),
        rop: 15,
        stockAmount: 10
    )
}

// MARK: - DTO Models
typealias ProductSummaryResponse = SuccessResponse<ProductSummaryData>

struct ProductSummaryData: JSONDecodable {
    let items: [ProductSummary]?
    let total: Int?
    let page: Int?
    let pageSize: Int?
    let totalPages: Int?
    let minUpdatedAt: String?
    let maxUpdatedAt: String?
    let summary: ProductSummaryCount?
    
    private enum CodingKeys: String, CodingKey {
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

struct ProductSummaryCount: JSONDecodable {
    let low: Int?
    let high: Int?
    let medium: Int?
    let total: Int?
    
    // This is new attribute after version DEV-161
    let empty: Int?
    let safe: Int?
    let almost: Int?
    let out: Int?

    private enum CodingKeys: String, CodingKey {
        case low = "Low"
        case high = "High"
        case medium = "Medium"
        case total
        case empty = "null"
        case safe = "Aman"
        case almost = "Menipis"
        case out = "Habis"
    }
}

struct ProductSummary: JSONDecodable {
    let id: String
    let productName: String?
    let asdTrend: String?
    let isAnomaly: Bool?
    let priorityLevel: String?
    let restockStatus: String?
    let stockStatus: String?
    let updatedAt: String?
    let analysisUpdatedAt: String?
    
    // This is new attribute after version DEV-161
    let rop: Int?
    let stockAmount: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case productName = "Product Name"
        case asdTrend = "asd_trend"
        case isAnomaly = "is_anomaly"
        case priorityLevel = "priority_level"
        case restockStatus = "restock_status"
        case stockStatus = "stock_status"
        case updatedAt = "updated_at"
        case analysisUpdatedAt = "analysis_update_at"
        case rop = "rop"
        case stockAmount = "stock_amount"
    }
}

// MARK: - Mapper
extension ProductSummary {
    func toProductSummaryUI(index: Int) -> ProductSummaryUI {
        ProductSummaryUI(
            id: self.id,
            index: index,
            name: self.productName ?? "Unknown Product",
            checkRecommendation: CheckRecommendationStatus.from(self.priorityLevel),
            stockStatus: StockStatus.from(self.stockStatus),
            updatedAt: self.updatedAt?.toDate(),
            analysisUpdatedAt: self.analysisUpdatedAt?.toDate(),
            rop: self.rop,
            stockAmount: self.stockAmount
        )
    }
}

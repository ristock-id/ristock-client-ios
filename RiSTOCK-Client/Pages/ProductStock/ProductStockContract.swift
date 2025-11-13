//
//  ProductStockContract.swift
//  RiSTOCK-Client
//
//  Created by Rico Tandrio on 07/11/25.
//

import Foundation
import UIKit

enum CheckProductStatus {
    case allProducts
    case needToBeChecked
    case alreadyChecked
}

enum CheckRecommendationStatus: String, CaseIterable {
    case now = "Cek Sekarang"
    case soon = "Cek Segera"
    case periodically = "Cek Berkala"
    case unmapped = "Tidak Terpetakan"
    
    var icon: String {
        switch self {
        case .now:
            return "exclamationmark.triangle.fill"
        case .soon:
            return "bell.fill"
        case .periodically:
            return "clock"
        case .unmapped:
            return "questionmark.circle.fill"
        }
    }
    
    var uiColor: UIColor {
        switch self {
        case .now:
            return Token.error600
        case .soon:
            return Token.warning650
        case .periodically:
            return Token.success500
        case .unmapped:
            return Token.gray600
        }
    }
}

enum SalesTrend: String, CaseIterable {
    case high = "Naik"
    case low = "Turun"
}

enum DemandStatus: String, CaseIterable {
    case normal = "Normal"
    case notNormal = "Tidak Normal"
}

enum StockStatus: String, CaseIterable {
    case safe = "Aman"
    case low = "Menipis"
    case out = "Habis"
    
    var accentColor: UIColor {
        switch self {
        case .safe:
            return Token.success700
        case .low:
            return Token.warning800
        case .out:
            return Token.error600
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .safe:
            return Token.success50
        case .low:
            return Token.warning50
        case .out:
            return Token.error50
        }
    }
}

enum ProductPlatform: String, CaseIterable {
    case tiktok, lazada, shopee
}

// MARK: - Product Model
struct Product: Identifiable {
    let id: String
    var name: String
    var sales: SalesTrend
    var demand: DemandStatus
    
    var salesCondition: SalesCondition
    var checkRecommendation: CheckRecommendationStatus
    
    var stockStatus: StockStatus? = nil
    var lastUpdated: Date
    var dailySalesArray: [DailySale]
    var salesTrendPct: Double
    var revenueTrendPct: Double
    var orderTrendPct: Double
    var analysisUpdatedAt: Date? = Date()
    
    var lastWeekSales: Int
    var thisWeekSales: Int
    var lastWeekRevenue: Double
    var thisWeekRevenue: Double
    var lastWeekOrders: Int
    var thisWeekOrders: Int
}

extension SalesCondition: Hashable {}
extension SalesCondition: Equatable {}

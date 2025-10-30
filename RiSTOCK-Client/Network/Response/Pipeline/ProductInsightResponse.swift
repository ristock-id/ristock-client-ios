//
//  ProductResponse.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 20/10/25.
//

import Foundation

typealias ProductInsightArrayResponse = JSONArray<ProductInsightResponse>

struct ProductInsightResponse: JSONDecodable {
    let id: String
    let productName: String
    let abcClass: String
    let xyzClass: String
    let abcXyzClass: String
    let volatilityLabel: String
    let asdTrend: String
    let asdDeltaCategory: String
    let asdDeltaPct: Double
    let asdAbsoluteDelta: Double
    let isAnomaly: Bool
    let anomalyType: String
    let detectionMethod: String
    let madScore: Double
    let anomalyThreshold: Double
    let priorityLevel: String
    let priorityScore: Int
    let actionRecommendation: String
    let restockStatus: String?
    let totalRevenue: Double
    let quantitySold: Double
    let dailyAvgSales: Double
    let asd7d: Double
    let asd14dAvg: Double
    let cv: Double
    let updatedAt: String
    let analysisUpdatedAt: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case productName = "Product Name"
        case abcClass = "abc_class"
        case xyzClass = "xyz_class"
        case abcXyzClass = "abc_xyz_class"
        case volatilityLabel = "volatility_label"
        case asdTrend = "asd_trend"
        case asdDeltaCategory = "asd_delta_category"
        case asdDeltaPct = "asd_delta_pct"
        case asdAbsoluteDelta = "asd_absolute_delta"
        case isAnomaly = "is_anomaly"
        case anomalyType = "anomaly_type"
        case detectionMethod = "detection_method"
        case madScore = "mad_score"
        case anomalyThreshold = "anomaly_threshold"
        case priorityLevel = "priority_level"
        case priorityScore = "priority_score"
        case actionRecommendation = "action_recommendation"
        case restockStatus = "restock_status"
        case totalRevenue = "total_revenue"
        case quantitySold = "quantity_sold"
        case dailyAvgSales = "daily_avg_sales"
        case asd7d = "asd_7d"
        case asd14dAvg = "asd_14d_avg"
        case cv
        case updatedAt = "updated_at"
        case analysisUpdatedAt = "analysis_update_at"
    }
    
    func toStockStatus(from restockStatus: String?) -> StockStatus? {
        guard let status = restockStatus else {
            return nil
        }
        
        switch status {
        case "aman":
            return .safe
        case "Aman":
            return .safe
        case "need_restock":
            return .low
        case "menipis":
            return .low
        case "habis":
            return .out
        case "overstocked":
            return .safe
        default:
            return nil
        }
    }
    
    func toDate(from dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter.date(from: dateString) ?? Date()
        
    }
    
    func toProduct() -> Product {
        let p = Product(
            id: self.id,
            name: self.productName,
            sales: self.asdTrend == "Increasing" ? SalesTrend.high : SalesTrend.low,
            demand: self.isAnomaly == true ? DemandStatus.normal : DemandStatus.notNormal,
            platforms: [.tiktok], // TODO: map platforms
//            stockStatus: self.restockStatus == "need_restock" ? StockStatus.low : nil, // TODO: map stock status
            stockStatus: toStockStatus(from: self.restockStatus),
            lastUpdated: toDate(from: self.updatedAt)
        )
        
        return p
    }
    
}


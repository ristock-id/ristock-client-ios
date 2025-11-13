//
//  ProductResponse.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 20/10/25.
//

import Foundation

typealias ProductInsightArrayResponse = JSONArray<ProductInsightResponse>

struct DailySales: JSONDecodable {
    let date: String
    let sales: Double
    
    private enum CodingKeys: String, CodingKey {
        case date
        case sales
    }
}

struct ProductInsightResponse: JSONDecodable {
    let id: String
    let productName: String?
    let asdTrend: String?
    let asdDeltaPct: Double?
    let asdAbsoluteDelta: Double?
    let isAnomaly: Bool?
    let priorityLevel: String?
    let restockStatus: String?
    let stockStatus: String?
    let totalRevenue: Double?
    let quantitySold: Double?
    let dailyAvgSales: Double?
    let asd7d: Double?
    let asd14dAvg: Double?
    let analysisUpdatedAt: String?
    let updatedAt: String?
    let lastWeekSales: Int?
    let thisWeekSales: Int?
    let salesTrendPct: Double?
    let lastWeekRevenue: Double?
    let thisWeekRevenue: Double?
    let revenueTrendPct: Double?
    let lastWeekOrders: Int?
    let thisWeekOrders: Int?
    let ordersTrendPct: Double?
    let dailySalesArray: [DailySales]
    
    // Optional fields not in provided JSON but kept for model consistency
    let abcClass: String?
    let xyzClass: String?
    let abcXyzClass: String?
    let volatilityLabel: String?
    let asdDeltaCategory: String?
    let anomalyType: String?
    let detectionMethod: String?
    let madScore: Double?
    let anomalyThreshold: Double?
    let priorityScore: Int?
    let actionRecommendation: String?
    let cv: Double?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case productName = "Product Name"
        case asdTrend = "asd_trend"
        case asdDeltaPct = "asd_delta_pct"
        case asdAbsoluteDelta = "asd_absolute_delta"
        case isAnomaly = "is_anomaly"
        case priorityLevel = "priority_level"
        case restockStatus = "restock_status"
        case stockStatus = "stock_status"
        case totalRevenue = "total_revenue"
        case quantitySold = "quantity_sold"
        case dailyAvgSales = "daily_avg_sales"
        case asd7d = "asd_7d"
        case asd14dAvg = "asd_14d_avg"
        case analysisUpdatedAt = "analysis_update_at"
        case updatedAt = "updated_at"
        case lastWeekSales = "last_week_sales"
        case thisWeekSales = "this_week_sales"
        case salesTrendPct = "sales_trend_pct"
        case lastWeekRevenue = "last_week_revenue"
        case thisWeekRevenue = "this_week_revenue"
        case revenueTrendPct = "revenue_trend_pct"
        case lastWeekOrders = "last_week_orders"
        case thisWeekOrders = "this_week_orders"
        case ordersTrendPct = "orders_trend_pct"
        case dailySalesArray = "daily_sales_array"
        
        // Optional/legacy fields
        case abcClass = "abc_class"
        case xyzClass = "xyz_class"
        case abcXyzClass = "abc_xyz_class"
        case volatilityLabel = "volatility_label"
        case asdDeltaCategory = "asd_delta_category"
        case anomalyType = "anomaly_type"
        case detectionMethod = "detection_method"
        case madScore = "mad_score"
        case anomalyThreshold = "anomaly_threshold"
        case priorityScore = "priority_score"
        case actionRecommendation = "action_recommendation"
        case cv
    }
    
    private func toStockStatus(from restockStatus: String?) -> StockStatus? {
        guard let status = restockStatus?.lowercased() else {
            return nil
        }
        
        switch status {
        case "aman":
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
    
    private func toCheckRecommendation(from action: String) -> CheckRecommendationStatus {
        switch action {
        case "High":
            return .now
        case "Medium":
            return .soon
        case "Low":
            return .periodically
        default:
            print("[WARNING] Unmapped action string: \(action == "" ? "empty" : action)")
            return .periodically
        }
    }
    
    func toSalesCondition(isAnomaly: Bool?) -> SalesCondition {
        guard let isAnomaly else { return .unknown }
        
        return isAnomaly ? .normal : .notNormal
    }
    
    func toDailySale(from dailySalesArray: [DailySales]) -> [DailySale] {
        return dailySalesArray.map {
            DailySale(
                dateString: $0.date,
                amount: Int($0.sales)
            )
        }
    }
    
    func toProduct() -> Product {
        let p = Product(
            id: self.id,
            name: self.productName ?? "",
            sales: self.asdTrend == "Increasing" ? SalesTrend.high : SalesTrend.low,
            demand: self.isAnomaly == true ? DemandStatus.normal : DemandStatus.notNormal,
            
            salesCondition: toSalesCondition(isAnomaly: self.isAnomaly),
            checkRecommendation: toCheckRecommendation(from: self.priorityLevel ?? ""),
            
            stockStatus: toStockStatus(from: self.restockStatus),
            lastUpdated: self.updatedAt?.toDate() ?? Date(),
            dailySalesArray: toDailySale(from: self.dailySalesArray),
            salesTrendPct: self.salesTrendPct ?? 0.0,
            revenueTrendPct: self.revenueTrendPct ?? 0.0,
            orderTrendPct: self.ordersTrendPct ?? 0.0,
            analysisUpdatedAt: self.analysisUpdatedAt?.toDate(),
            lastWeekSales: self.lastWeekSales ?? 0,
            thisWeekSales: self.thisWeekSales ?? 0,
            lastWeekRevenue: self.lastWeekRevenue ?? 0.0,
            thisWeekRevenue: self.thisWeekRevenue ?? 0.0,
            lastWeekOrders: self.thisWeekOrders ?? 0,
            thisWeekOrders: self.thisWeekOrders ?? 0
        )
        
        return p
    }
    
}

//
//  ProductDetailResponse.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 13/11/25.
//

import Foundation

// MARK: - ProductDetailUI
struct ProductDetailUI: Identifiable, Equatable {
    let id: String
    var index: Int = -1
    var name: String
    var sales: SalesTrend
    var demand: DemandStatus
    
    var salesCondition: SalesCondition
    var checkRecommendation: CheckRecommendationStatus
    
    var stockStatus: StockStatus? = nil
    var updatedAt: Date? = nil
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
    
    var isRestockStatusExpired: Bool {
        guard let updatedAt = updatedAt, let analysisUpdatedAt = analysisUpdatedAt else {
            return false
        }
        return updatedAt < analysisUpdatedAt
    }
}

// MARK: - DTO Models
typealias ProductDetailResponse = SuccessResponse<ProductDetailData>

struct ProductDetailData: JSONDecodable {
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
    
    // Optional fields for model consistency
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
        
        // Optional/legacy
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
}

// MARK: Mapper
extension ProductDetailData {
    func toProductDetailUI(index: Int = -1) -> ProductDetailUI {
        return ProductDetailUI(
            id: id,
            index: index,
            name: productName ?? "Unknown Product",
            sales: self.asdTrend == "Increasing" ? SalesTrend.high : SalesTrend.low,
            demand: self.isAnomaly == true ? DemandStatus.normal : DemandStatus.notNormal,
            salesCondition: toSalesCondition(isAnomaly: self.isAnomaly),
            checkRecommendation: CheckRecommendationStatus.from(self.restockStatus),
            stockStatus: StockStatus.from(self.stockStatus),
            updatedAt: updatedAt?.toDate(),
            dailySalesArray: toDailySale(from: self.dailySalesArray),
            salesTrendPct: salesTrendPct ?? 0.0,
            revenueTrendPct: revenueTrendPct ?? 0.0,
            orderTrendPct: ordersTrendPct ?? 0.0,
            analysisUpdatedAt: analysisUpdatedAt?.toDate(),
            lastWeekSales: lastWeekSales ?? 0,
            thisWeekSales: thisWeekSales ?? 0,
            lastWeekRevenue: lastWeekRevenue ?? 0.0,
            thisWeekRevenue: thisWeekRevenue ?? 0.0,
            lastWeekOrders: lastWeekOrders ?? 0,
            thisWeekOrders: thisWeekOrders ?? 0
        )
    }
    
    func toDailySale(from dailySalesArray: [DailySales]) -> [DailySale] {
        return dailySalesArray.map {
            DailySale(
                dateString: $0.date,
                amount: Int($0.sales)
            )
        }
    }
    
    func toSalesCondition(isAnomaly: Bool?) -> SalesCondition {
        guard let isAnomaly else { return .unknown }
        
        return isAnomaly ? .normal : .notNormal
    }
}

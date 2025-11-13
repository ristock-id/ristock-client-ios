import Foundation

// MARK: - Product Model
struct Product: Identifiable, Equatable {
    let id: String
    var index: Int = -1
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
    
    static let sample = Product(
        id: "1",
        name: "Sample Product",
        sales: .high,
        demand: .normal,
        salesCondition: .normal,
        checkRecommendation: .now,
        stockStatus: nil,
        lastUpdated: Date(),
        dailySalesArray: [],
        salesTrendPct: -12.5,
        revenueTrendPct: -8.3,
        orderTrendPct: -15.0,
        analysisUpdatedAt: Date(),
        lastWeekSales: 100,
        thisWeekSales: 120,
        lastWeekRevenue: 2000.0,
        thisWeekRevenue: 2500.0,
        lastWeekOrders: 80,
        thisWeekOrders: 95
    )
}

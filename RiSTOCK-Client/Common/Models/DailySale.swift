import Foundation
import Charts

//  MARK - Daily Sale
struct DailySale: Identifiable, Plottable, Equatable {
    let id: UUID = UUID()
    let dateString: String
    let amount: Int
    let date: Date
    
    var primitivePlottable: String {
        dateString
    }
    
    init?(primitivePlottable: String) {
        return nil
    }
    
    init(dateString: String, amount: Int) {
        self.dateString = dateString
        self.amount = amount
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.date = formatter.date(from: dateString) ?? .now
    }
    
    // Custom equality based on meaningful properties, not UUID
    static func == (lhs: DailySale, rhs: DailySale) -> Bool {
        lhs.dateString == rhs.dateString && 
        lhs.amount == rhs.amount &&
        lhs.date == rhs.date
    }
}
import Foundation
import SwiftUI

enum StockStatus: String, CaseIterable {
    case safe = "aman"
    case low = "menipis"
    case out = "habis"
    
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
    
    var filterString: String {
        switch self {
        case .safe:
            return "aman"
        case .low:
            return "menipis"
        case .out:
            return "habis"
        }
    }
    
    /// Helper to create StockStatus from a string value
    ///
    /// - Parameter value: The string value representing the stock status
    /// - Returns: The corresponding StockStatus enum case, or nil if the value is invalid
    static func from(_ value: String?) -> StockStatus? {
        guard let status = value?.lowercased() else { return nil }
        switch status {
        case "aman":
            return .safe
        case "menipis":
            return .low
        case "habis":
            return .out
        default:
            return nil
        }
    }
}

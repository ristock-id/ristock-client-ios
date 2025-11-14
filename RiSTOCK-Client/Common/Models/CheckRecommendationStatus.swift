import Foundation
import UIKit
import SwiftUI

enum CheckRecommendationStatus: String, CaseIterable {
    case now = "Cek Sekarang"
    case soon = "Cek Segera"
    case periodically = "Cek Berkala"
    
    var icon: Image {
        switch self {
        case .now:
            return Image(systemName: "exclamationmark.triangle.fill")
        case .soon:
            return Image(systemName: "bell.fill")
        case .periodically:
            return Image(uiImage: RiSTOCKIcon.clockIconSuccess500.image)
        }
    }
    
    var nsColor: UIColor {
        switch self {
        case .now:
            return Token.error600
        case .soon:
            return Token.warning650
        case .periodically:
            return Token.success500
        }
    }
    
    var filterString: String {
        switch self {
        case .now:
            return "High"
        case .soon:
            return "Medium"
        case .periodically:
            return "Low"
        }
    }
    
    /// Initialize from priority level string
    ///
    /// - Parameter value: Priority level string
    /// - Returns: Corresponding CheckRecommendationStatus or nil if unmapped
    static func from(_ value: String?) -> CheckRecommendationStatus {
        switch value {
        case "High": return .now
        case "Medium": return .soon
        case "Low": return .periodically
        default:
            print("[WARNING] Unmapped priorityLevel: \(value ?? "nil"), defaulting to .periodically")
            return .periodically
        }
    }
}

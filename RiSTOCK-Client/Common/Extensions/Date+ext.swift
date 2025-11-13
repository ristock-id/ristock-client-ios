//
//  Date+ext.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 04/11/25.
//

import Foundation

extension Date {
    func toISOString() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }
    
    func toDisplayDateString(cropped: Bool = false) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        
        if cropped {
            formatter.dateFormat = "dd MMM yyyy"
        }
        
        return formatter.string(from: self)
    }
    
    func isMoreThanTwoWeeks() -> Bool {
        let twoWeeks: TimeInterval = 14 * 24 * 60 * 60
        
        return abs(timeIntervalSinceNow) > twoWeeks
    }
}

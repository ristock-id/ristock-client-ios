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
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Prevent time zone issues by setting it to UTC
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        formatter.dateFormat = cropped ? "dd MMM yyyy" : "dd MMMM yyyy"
        
        return formatter.string(from: self)
    }
    
    func isMoreThanTwoWeeks() -> Bool {
        let twoWeeks: TimeInterval = 14 * 24 * 60 * 60
        
        return abs(timeIntervalSinceNow) > twoWeeks
    }
    
    /// Checks if the date is more than the specified number of days from now.
    ///
    /// - Parameter days: The number of days to compare against.
    /// - Returns: `true` if the date is more than the specified days from now (either in the past or future), otherwise `false`.
    func isMoreThan(days: Int) -> Bool {
        let interval: TimeInterval = TimeInterval(days * 24 * 60 * 60)
        
        return abs(timeIntervalSinceNow) > interval
    }
    
    static func fromISO8601String(_ isoString: String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: isoString) ?? Date()
    }
    
    /// Converts the date to a string adjusted to Asia/Jakarta timezone.
    ///
    /// - Parameters:
    ///   - format: The date format string (default is `"yyyy-MM-dd"`).
    ///   - setTimeTo: Optional time string (`"HH:mm:ss"`) to override the time portion.
    /// - Returns: A formatted date string in Jakarta local time.
    func toString(format: String = "yyyy-MM-dd", setTimeTo timeString: String? = nil) -> String {
        guard let jakartaTimeZone = TimeZone(identifier: "Asia/Jakarta") else {
            return ""
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = jakartaTimeZone

        var dateToFormat = self

        // Apply custom time if provided
        if let timeString = timeString {
            let timeParts = timeString.split(separator: ":").compactMap { Int($0) }
            if timeParts.count == 3 {
                var components = calendar.dateComponents([.year, .month, .day], from: dateToFormat)
                components.hour = timeParts[0]
                components.minute = timeParts[1]
                components.second = timeParts[2]
                if let adjustedDate = calendar.date(from: components) {
                    dateToFormat = adjustedDate
                }
            }
        }

        // Format date for display in Jakarta time
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = jakartaTimeZone

        return formatter.string(from: dateToFormat)
    }

}

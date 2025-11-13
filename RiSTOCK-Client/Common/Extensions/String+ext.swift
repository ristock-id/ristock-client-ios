//
//  String+ext.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 04/11/25.
//

import Foundation

extension String {
    func fromISO8601ToDisplayFormat() -> String {
        let isoFormatter = ISO8601DateFormatter()
        
        guard let date = isoFormatter.date(from: self) else {
            return self
        }
        
        let displayFormatter = DateFormatter()
        
        displayFormatter.dateFormat = "dd MMMM yyyy"
        
        displayFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        return displayFormatter.string(from: date)
    }
    
    /// Converts an ISO8601-like date string into a `Date` object,
    /// assuming `Asia/Jakarta` as the default timezone.
    ///
    /// - Parameters:
    ///   - gmt: When `true`, parses as GMT (UTC); otherwise, uses Asia/Jakarta.
    ///   - setTimeTo: Optional time string (`"HH:mm:ss"`) to override the parsed time.
    /// - Returns: A `Date` parsed from the string, adjusted if needed.
    func toDate(gmt: Bool = false, setTimeTo timeString: String? = nil) -> Date {
        guard let jakartaTimeZone = TimeZone(identifier: "Asia/Jakarta") else {
            return Date()
        }
        
        guard let gmtTimeZone = TimeZone(secondsFromGMT: 0) else {
            return Date()
        }
        
        // Base date formatter for ISO-like strings
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = gmt ? gmtTimeZone : jakartaTimeZone
        
        guard var date = formatter.date(from: self) else {
            return Date()
        }
        
        // If a custom time override is provided (e.g. "23:59:59")
        if let timeString = timeString {
            let timeParts = timeString.split(separator: ":").compactMap { Int($0) }
            if timeParts.count == 3 {
                var calendar = Calendar(identifier: .gregorian)
                calendar.timeZone = gmt ? gmtTimeZone : jakartaTimeZone
                
                var components = calendar.dateComponents([.year, .month, .day], from: date)
                components.hour = timeParts[0]
                components.minute = timeParts[1]
                components.second = timeParts[2]
                
                date = calendar.date(from: components) ?? date
            }
        }
        
        return date
    }
    
    func toDisplayFormat(from inputFormat: String, to outputFormat: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = inputFormat
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = outputFormat
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = inputFormatter.date(from: self) {
            return outputFormatter.string(from: date)
        } else {
            return self
        }
    }
    
    /// Converts the string representing a number into a currency formatted string.
    ///
    /// - Parameters:
    ///  - localeIdentifier: The locale identifier for formatting (default is "id_ID").
    ///  - currencyCode: The currency code (default is "IDR").
    ///  - withCurrencySymbol: Whether to include the currency symbol (default is `false`).
    /// - Returns: A formatted currency string.
    func toCurrencyFormat(
        localeIdentifier: String = "id_ID",
        currencyCode: String = "IDR",
        withCurrencySymbol: Bool = false
    ) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: localeIdentifier)
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 0
        
        if !withCurrencySymbol {
            formatter.currencySymbol = ""
            formatter.positivePrefix = ""
            formatter.negativePrefix = "-"
        }
        
        let number = Double(self) ?? 0.0
        
        return formatter.string(from: NSNumber(value: number))?.trimmingCharacters(in: .whitespaces) ?? self
    }

}

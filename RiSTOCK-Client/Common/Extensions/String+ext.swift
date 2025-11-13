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
    
    func toDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter.date(from: self) ?? Date()
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

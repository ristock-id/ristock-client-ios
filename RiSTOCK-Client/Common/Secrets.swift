//
//  Secrets.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 19/10/25.
//

import Foundation

final class Secrets {
    static let shared = Secrets()

    private var secrets: [String: Any] = [:]

    private init() {
        if let path: String = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict: [String: Any] = NSDictionary(contentsOfFile: path) as? [String: Any] {
            secrets = dict
        }
    }

    func string(forKey key: String) -> String? {
        guard let value = secrets[key] else {
            return nil
        }
        if let stringValue = value as? String {
            return stringValue
        }
        if let numberValue = value as? NSNumber {
            return numberValue.stringValue
        }
        return nil
    }

    func url(forKey key: String) -> URL? {
        guard let stringValue = string(forKey: key) else {
            return nil
        }
        return URL(string: stringValue)
    }

    func integer(forKey key: String) -> Int? {
        guard let value = secrets[key] else {
            return nil
        }
        if let intValue = value as? Int {
            return intValue
        }
        if let stringValue = value as? String {
            return Int(stringValue)
        }
        if let numberValue = value as? NSNumber {
            return numberValue.intValue
        }
        return nil
    }

    func bool(forKey key: String) -> Bool? {
        guard let value = secrets[key] else {
            return nil
        }
        if let boolValue = value as? Bool {
            return boolValue
        }
        if let stringValue = value as? NSString {
            return stringValue.boolValue
        }
        if let numberValue = value as? NSNumber {
            return numberValue.boolValue
        }
        return nil
    }
}

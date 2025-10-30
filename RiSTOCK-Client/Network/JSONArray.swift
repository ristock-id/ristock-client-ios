//
//  JSONArray.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 19/10/25.
//

import Foundation

protocol JSONArrayProtocol {
    init(jsonArray: [JSONObject]) throws
}

extension JSONArray: JSONArrayProtocol {}

struct JSONArray<T: JSONDecodable>: JSONDecodable {
    let values: [T]

    init(json: JSONObject) throws {
        throw NSError(domain: "JSONArray init expects a top-level array, not an object", code: -1)
    }

    init(jsonArray: [JSONObject]) throws {
        self.values = try jsonArray.map { try T(json: $0) }
    }
}

struct JSONEncodableArray<T: JSONEncodable>: JSONEncodable {
    let values: [T]

    func toDictionary() -> JSONObject? {
        return nil
    }

    func toArray() -> [JSONObject]? {
        return values.compactMap { $0.toDictionary() }
    }
}

//
//  SuccessResponse.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 21/10/25.
//

import Foundation

struct SuccessResponse<T: JSONDecodable>: JSONDecodable {
    let code: Int
    let message: String
    let data: T
    
    init(json: JSONObject) throws {
        guard let code = json["code"] as? Int else {
            throw NSError(domain: "Missing code", code: -1)
        }
        self.code = code

        guard let message = json["message"] as? String else {
            throw NSError(domain: "Missing message", code: -1)
        }
        self.message = message

        if let array = json["data"] as? [JSONObject] {
            if let arrayType = T.self as? JSONArrayProtocol.Type {
                self.data = try arrayType.init(jsonArray: array) as! T
            } else {
                throw NSError(domain: "T does not support jsonArray init", code: -1)
            }
        } else if let dict = json["data"] as? JSONObject {
            self.data = try T(json: dict)
        } else {
            throw NSError(domain: "Invalid data type", code: -1)
        }
    }

    init(code: Int, message: String, data: T) {
        self.code = code
        self.message = message
        self.data = data
    }
}

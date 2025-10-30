//
//  User.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 19/10/25.
//

struct User: JSONDecodable {
    let id: String
    let email: String
    let name: String
    let createdAt: String
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case createdAt = "created_at"
        case isActive = "is_active"
    }
}

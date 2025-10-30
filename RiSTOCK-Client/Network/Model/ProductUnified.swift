//
//  ProductUnified.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 20/10/25.
//

struct ProductUnified: JSONDecodable {
    let id: String
    let status: String
    let priority: String
    let restockStatus: String
    let createdAt: String
    let createdBy: String
    let updatedAt: String
    let updatedBy: String
    let deletedAt: String
    let deletedBy: String
    let isActive: Bool

    private enum CodingKeys: String, CodingKey {
        case id
        case status
        case priority
        case restockStatus = "restock_status"
        case createdAt = "created_at"
        case createdBy = "created_by"
        case updatedAt = "updated_at"
        case updatedBy = "updated_by"
        case deletedAt = "deleted_at"
        case deletedBy = "deleted_by"
        case isActive = "is_active"
    }
}

typealias ProductUnifiedModelArray = JSONArray<ProductUnified>


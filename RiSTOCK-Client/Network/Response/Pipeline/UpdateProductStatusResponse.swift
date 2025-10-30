//
//  UpdateProductStatusRequest.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 24/10/25.
//

import Foundation

struct UpdateProductStatusRequest: JSONEncodable {
    let productId: String
    let status: String
    
    private enum CodingKeys: String, CodingKey {
        case productId = "id"
        case status = "restock_status"
    }
    
    init (productId: String, status: StockStatus) {
        self.productId = productId
        self.status = status.rawValue.lowercased()
    }
}

struct UpdateProductStatusArrayRequest: JSONEncodable {
    let products: [UpdateProductStatusRequest]
    
    private enum CodingKeys: String, CodingKey {
        case products = "products"
    }
    
    init (products: [UpdateProductStatusRequest]) {
        self.products = products
    }
}

//
//  UpdateStockRequest.swift
//  RiSTOCK-Client
//
//  Created by Teuku Fazariz Basya on 26/11/25.
//

struct UpdateProductStockRequest: JSONEncodable {
    let productId: String
    let quantity: Int
    
    private enum CodingKeys: String, CodingKey {
        case productId = "product_unified_id"
        case quantity = "new_stock_count"
    }
        
    init (productId: String, quantity: Int) {
        self.productId = productId
        self.quantity = quantity
    }
}

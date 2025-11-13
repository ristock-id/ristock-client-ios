//
//  ProductStockContract.swift
//  RiSTOCK-Client
//
//  Created by Rico Tandrio on 07/11/25.
//

import Foundation
import SwiftUI
import UIKit
import Charts

enum CheckProductStatus {
    case allProducts
    case needToBeChecked
    case alreadyChecked
}

enum SalesTrend: String, CaseIterable {
    case high = "Naik"
    case low = "Turun"
}

enum DemandStatus: String, CaseIterable {
    case normal = "Normal"
    case notNormal = "Tidak Normal"
}

enum ProductPlatform: String, CaseIterable {
    case tiktok, lazada, shopee
}

extension SalesCondition: Hashable {}
extension SalesCondition: Equatable {}

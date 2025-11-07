//
//  ProductStockViewModel.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 19/10/25.
//

import Foundation
import Combine
import SwiftUI

struct CheckCount {
    var updated: Int = 0
    var total: Int = 0
}

enum ErrorProductStockView {
    case noFilterResults
    case noSearchResults
    case noProductExists
    case apiFail
    
    var message: String {
        switch self {
        case .noFilterResults:
            return "Tidak ada produk yang sesuai.\nUbah atau reset filter."
        case .noSearchResults:
            return "Tidak ada hasil yang ditemukan.\nCoba gunakan kata kunci lain."
        case .noProductExists:
            return "Data Anda Kosong. \nUpload file untuk mulai cek stok!"
        case .apiFail:
            return "Gagal memuat data produk.\nCoba lagi nanti."
        }
    }
}

class ProductStockViewModel: ObservableObject {

    @Published var products: [Product] = [] {
        didSet {
            self.countProducts = products.count
        }
    }
    
    @Published var countProducts: Int = 0
    
    @Published var filteredProducts: [Product] = []

    @Published var isLoading: Bool = false

    @Published var countCheckNow: CheckCount = CheckCount()
    @Published var countCheckSoon: CheckCount = CheckCount()
    @Published var countCheckPeriodically: CheckCount = CheckCount()

    @Published var errorProductStockView: ErrorProductStockView? = nil
    
    private let deviceId: String
    
    private var pipelineFetcher: PipelineFetcherProtocol
    
    init(pipelineFetcher: PipelineFetcherProtocol = PipelineFetcher(), deviceId: String) {
        self.pipelineFetcher = pipelineFetcher
        self.deviceId = deviceId
        
        fetchProducts()
    }
    
    private func countProductsByCheckRecommendation() {
        let nowProducts = self.products.filter { $0.checkRecommendation == .now }
        self.countCheckNow.total = nowProducts.count
        self.countCheckNow.updated = nowProducts.filter { $0.stockStatus != nil }.count
        
        let soonProducts = self.products.filter { $0.checkRecommendation == .soon }
        self.countCheckSoon.total = soonProducts.count
        self.countCheckSoon.updated = soonProducts.filter { $0.stockStatus != nil }.count

        let periodicallyProducts = self.products.filter { $0.checkRecommendation == .periodically }
        self.countCheckPeriodically.total = periodicallyProducts.count
        self.countCheckPeriodically.updated = periodicallyProducts.filter { $0.stockStatus != nil }.count
    }
}

extension ProductStockViewModel {
    @MainActor
    func fetchProducts() {
        self.isLoading = true
        
        pipelineFetcher.get(clientID: self.deviceId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    
                    let mappedProduct = response.data.values.map { product in
                        product.toProduct()
                    }
                    
                    self.products = mappedProduct
                    self.filteredProducts = mappedProduct
                    
                    if self.products.isEmpty {
                        self.errorProductStockView = .noProductExists
                    } else {
                        self.countProductsByCheckRecommendation()
                        
                        self.errorProductStockView = nil
                    }
                    self.isLoading = false
                case .failure(let error):
                    print("Failed to fetch products:", error)
                    self.errorProductStockView = .apiFail
                    self.isLoading = false
                }
            }
        }
    }
    
    @MainActor
    func fetchUpdateStockStatus(with productId: String, to status: StockStatus, callback: @escaping (() -> Void)) {
        self.isLoading = true
        
        let products: [UpdateProductStatusRequest] = [UpdateProductStatusRequest(productId: productId, status: status)]
        
        let request: UpdateProductStatusArrayRequest = UpdateProductStatusArrayRequest(products: products)
        
        pipelineFetcher.updateStatusStock(clientID: self.deviceId, request: request) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    callback()
                    self.isLoading = false
                case .failure(let error):
                    print("Failed to fetch products:", error)
                    self.isLoading = false
                }
            }
        }
    }
}

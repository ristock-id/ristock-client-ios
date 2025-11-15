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
    
    // MARK: - Filters
    // These properties now trigger a new API call.
    @Published var selectedCheckRecommendationFilter: Set<CheckRecommendationStatus> = [] {
        didSet { resetPageAndFetch() }
    }
    
    @Published var selectedStockStatusFilter: Set<StockStatus> = [] {
        didSet { resetPageAndFetch() }
    }
    
    @Published var searchText: String = ""
    
    @Published var startDateFilter: Date? = nil {
        didSet { resetPageAndFetch() }
    }
    
    @Published var endDateFilter: Date? = nil {
        didSet { resetPageAndFetch() }
    }

    // MARK: - Pagination
    // These properties also trigger a new API call.
    @Published var selectedPageSize = 20 {
        didSet { fetchProductsSummary() }
    }
    
    @Published var currentPage = 1 {
        didSet { fetchProductsSummary() }
    }
    
    @Published var totalPages = 1
    
    // MARK: - Data Properties
    // This is now the single source of truth for the UI, populated directly by the API.
    @Published var products: [ProductSummaryUI] = []
    
    // MARK: - UI State Properties
    @Published var totalProducts: Int = 0 // Renamed from countProducts
    @Published var isLoading: Bool = false
    @Published var countCheckNow: CheckCount = CheckCount()
    @Published var countCheckSoon: CheckCount = CheckCount()
    @Published var countCheckPeriodically: CheckCount = CheckCount()
    @Published var dateJustFiltered: Bool = false // This might be handled differently now
    @Published var errorProductStockView: ErrorProductStockView? = nil
    @Published var validTill: Date? = nil
    
    @Published var startDate: Date = Date.distantPast
    @Published var endDate: Date = Date.distantFuture
    
    @Published var isChecked: Bool? = nil {
        didSet { resetPageAndFetch() }
    }
    
    // MARK: - Private Properties
    private let deviceId: String
    private var pipelineFetcher: PipelineFetcherProtocol
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Init
    init(pipelineFetcher: PipelineFetcherProtocol = PipelineFetcher(), deviceId: String) {
        self.pipelineFetcher = pipelineFetcher
        self.deviceId = deviceId
        
        // Debounce search text, then trigger an API fetch
        $searchText
            .debounce(for: .milliseconds(800), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.resetPageAndFetch()
            }
            .store(in: &cancellables)
        
        fetchProductsSummary()
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "clientId")
    }
    
    // MARK: - Filtering
    
    // This function is called when a filter changes.
    // It resets the page to 1 and fetches new data.
    private func resetPageAndFetch() {
        // Only fetch if the page is not already 1.
        // If it is 1, the `didSet` for `currentPage` will call fetchProducts().
        if currentPage == 1 {
            fetchProductsSummary()
        } else {
            currentPage = 1 // This will trigger fetchProducts() via its didSet
        }
    }
    
    // MARK: - Public Functions
    
    private func clearFilters() {
        self.selectedStockStatusFilter = []
        self.selectedCheckRecommendationFilter = []
        self.startDateFilter = nil
        self.endDateFilter = nil
        self.searchText = ""
        // Calling resetPageAndFetch() is not needed here,
        // as changing the properties above will trigger it.
    }

    // Refresh view explicitly, recomputing everything
    func forceRefresh() {
        // Re-fetch both summary and product data
        fetchProductsSummary()
    }
}

// MARK: - API Calls
extension ProductStockViewModel {
    @MainActor
    func fetchProductsSummary() {
        self.isLoading = true
        self.errorProductStockView = nil // Clear previous errors
        
        pipelineFetcher.getProductsSummary(
            clientID: self.deviceId,
            page: self.currentPage,
            itemsPerPage: self.selectedPageSize,
            query: self.searchText,
            stockStatus: self.selectedStockStatusFilter,
            checkRecommendationStatus: self.selectedCheckRecommendationFilter,
            startDate: self.startDateFilter,
            endDate: self.endDateFilter,
            isChecked: self.isChecked
        ) { [weak self] result in
            guard let self = self else { return }
            
            // Use DispatchQueue.main.async for the @MainActor function
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    
                    var tempProducts: [ProductSummaryUI] = []
                    
                    if let datas = response.data.items {
                        for (index, _) in datas.enumerated() {
                            tempProducts.append(datas[index].toProductSummaryUI(
                                index: (index + 1) + ((self.currentPage - 1) * self.selectedPageSize)
                            ))
                        }
                    }
                    
                    self.products = tempProducts
                    
                    // Update pagination and total count from the API response
                    self.totalPages = response.data.totalPages ?? 1
                    self.totalProducts = response.data.total ?? 0
                    
                    // Summary
                    if let summary = response.data.summary {
                        self.countCheckNow = CheckCount(
                            updated: summary.low ?? 0,
                            total: response.data.total ?? 0
                        )
                        self.countCheckSoon = CheckCount(
                            updated: summary.medium ?? 0,
                            total: response.data.total ?? 0
                        )
                        self.countCheckPeriodically = CheckCount(
                            updated: summary.high ?? 0,
                            total: response.data.total ?? 0
                        )
                    }
                    
                    // Update calendar filter start and end date
                    if let minUpdatedAt = response.data.minUpdatedAt?.toDate(setTimeTo: "00:00:00") {
                        self.startDate = minUpdatedAt
                    }
                    
                    if let maxUpdatedAt = response.data.maxUpdatedAt?.toDate(setTimeTo: "23:59:59") {
                        self.endDate = maxUpdatedAt
                        self.validTill = maxUpdatedAt.addingTimeInterval(7 * 24 * 60 * 60) // +7 days
                    }

                    // Update error states based on the API response
                    if self.totalProducts == 0 {
                        if !self.searchText.isEmpty {
                            self.errorProductStockView = .noSearchResults
                        } else if !self.selectedCheckRecommendationFilter.isEmpty || !self.selectedStockStatusFilter.isEmpty || self.startDateFilter != nil || self.endDateFilter != nil {
                            self.errorProductStockView = .noFilterResults
                        } else {
                            self.errorProductStockView = .noProductExists
                        }
                    } else {
                        self.errorProductStockView = nil
                    }
                    
                case .failure(let error):
                    print("Failed to fetch products:", error)
                    self.errorProductStockView = .apiFail
                    self.products = []
                    self.totalProducts = 0
                    self.totalPages = 1
                }
            }
        }
    }
    
    @MainActor
    func fetchCheckRecommendationSummary() {
        self.isLoading = true
        
        pipelineFetcher.getCheckRecommendationSummary(
            clientID: self.deviceId
        ) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    // Assuming your API response keys are 'low', 'medium', 'high'
                    // and 'total' as provided in your example.
                    self.countCheckNow = CheckCount(updated: response.data.low, total: response.data.total)
                    self.countCheckSoon = CheckCount(updated: response.data.medium, total: response.data.total)
                    self.countCheckPeriodically = CheckCount(updated: response.data.high, total: response.data.total)
                    
                case .failure(let error):
                    print("Failed to fetch check recommendation summary:", error)
                    // Optionally set an error state for the summary cards
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
                self.isLoading = false
                switch result {
                case .success(_):
                    callback()
                case .failure(let error):
                    print("Failed to update stock status:", error)
                }
            }
        }
    }
}

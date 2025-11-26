//
//  PipelineFetcher.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 21/10/25.
//

import Foundation

protocol PipelineFetcherProtocol: AnyObject {
    func get(
        clientID: String,
        page: Int,
        itemsPerPage: Int,
        query: String?,
        stockStatus: Set<StockStatus>?,
        checkRecommendationStatus: Set<CheckRecommendationStatus>?,
        startDate: Date?,
        endDate: Date?,
        completion: @escaping (Result<SuccessResponse<ProductInsightPaginationResponse>, NetworkServiceError>) -> Void
    )
    
    func updateStatusStock(
        clientID: String,
        request: UpdateProductStatusArrayRequest,
        completion: @escaping (Result<SuccessResponse<UpdateProductStatusResponse>, NetworkServiceError>) -> Void
    )
    
    func updateProductStock(
        clientID: String,
        request: UpdateProductStockRequest,
        completion: @escaping (Result<SuccessResponse<UpdateProductStatusResponse>, NetworkServiceError>) -> Void
    )
    
    func getCheckRecommendationSummary(
        clientID: String,
        completion: @escaping (Result<SuccessResponse<CheckRecommendationSummaryResponse>, NetworkServiceError>) -> Void
    )
    
    func getProductsSummary(
        clientID: String,
        page: Int,
        itemsPerPage: Int,
        query: String?,
        stockStatus: Set<StockStatus>?,
        checkRecommendationStatus: Set<CheckRecommendationStatus>?,
        startDate: Date?,
        endDate: Date?,
        isChecked: Bool?,
        stockAmount: StockAmount?,
        completion: @escaping (Result<ProductSummaryResponse, NetworkServiceError>) -> Void
    )
    
    func getProductDetail(
        clientID: String,
        productID: String,
        completion: @escaping (Result<ProductDetailResponse, NetworkServiceError>) -> Void
    )
}

final class PipelineFetcher: PipelineFetcherProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func get(
        clientID: String = "",
        page: Int = 1,
        itemsPerPage: Int = 20,
        query: String? = nil,
        stockStatus: Set<StockStatus>? = nil,
        checkRecommendationStatus: Set<CheckRecommendationStatus>? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        completion: @escaping (Result<SuccessResponse<ProductInsightPaginationResponse>, NetworkServiceError>) -> Void
    ) {

        var parameters: [String: Any] = [
            "page": page,
            "page_size": itemsPerPage
        ]
        
        if let query = query, !query.isEmpty {
            parameters["query"] = query
        }
        
        if let stockStatus = stockStatus, !stockStatus.isEmpty {
            parameters["stock_status"] = stockStatus.map { $0.filterString }
        }
        
        if let checkRecommendationStatus = checkRecommendationStatus, !checkRecommendationStatus.isEmpty {
            parameters["check_recommendation"] = checkRecommendationStatus.map { $0.filterString }
        }
        
        // Add optional dates formatted as "YYYY-MM-DD"
        if let startDate = startDate {
            parameters["start_date"] = startDate.toString(format: "YYYY-MM-dd", setTimeTo: "00:00:01")
        }
        
        if let endDate = endDate {
            parameters["end_date"] = endDate.toString(format: "YYYY-MM-dd", setTimeTo: "23:59:59")
        }
        
        networkService.request(
            urlString: PipelineEndpoint.get.urlString,
            method: .get,
            parameters: parameters,
            headers: [
                "Client-Id": clientID
            ],
            body: nil,
            completion: completion
        )
    }
    
    func getCheckRecommendationSummary(
        clientID: String = "",
        completion: @escaping (Result<SuccessResponse<CheckRecommendationSummaryResponse>, NetworkServiceError>) -> Void
    ) {
        networkService.request(
            urlString: PipelineEndpoint.getCheckRecommendationSummary.urlString,
            method: .get,
            parameters: [:],
            headers: ["Client-Id": clientID],
            body: nil,
            completion: completion
        )
    }
    
    func updateStatusStock(
        clientID: String = "",
        request: UpdateProductStatusArrayRequest,
        completion: @escaping (Result<SuccessResponse<UpdateProductStatusResponse>, NetworkServiceError>) -> Void
    ) {
        
        networkService.request(
            urlString: PipelineEndpoint.updateStatusStock.urlString,
            method: .post,
            parameters: [:],
            headers: ["Client-Id": clientID],
            body: request,
            completion: completion
        )
    }
    
    func triggerPipeline(
        clientID: String = "",
        completion: @escaping (Result<SuccessResponse<ProductInsightArrayResponse>, NetworkServiceError>) -> Void
    ) {
        networkService.request(
            urlString: PipelineEndpoint.triggerPipeline.urlString,
            method: .get,
            parameters: [:],
            headers: ["Client-Id": clientID],
            body: nil
        ) { result in
            completion(self.normalizePipelineResult(result))
        }
    }
    
    func updateProductStock(
        clientID: String = "",
        request: UpdateProductStockRequest,
        completion: @escaping (Result<SuccessResponse<UpdateProductStatusResponse>, NetworkServiceError>) -> Void
    ) {
        networkService.request(
            urlString: PipelineEndpoint.updateProductStock.urlString,
            method: .post,
            parameters: [:],
            headers: ["Client-Id": clientID],
            body: request,
            completion: completion
        )
    }

    func getProductsSummary(
        clientID: String = "",
        page: Int = 1,
        itemsPerPage: Int = 20,
        query: String? = nil,
        stockStatus: Set<StockStatus>? = nil,
        checkRecommendationStatus: Set<CheckRecommendationStatus>? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        isChecked: Bool? = nil,
        stockAmount: StockAmount?,
        completion: @escaping (Result<ProductSummaryResponse, NetworkServiceError>) -> Void
    ) {

        var parameters: [String: Any] = [
            "page": page,
            "page_size": itemsPerPage
        ]
        
        if let query = query, !query.isEmpty {
            parameters["query"] = query
        }
        
        if let stockStatus = stockStatus, !stockStatus.isEmpty {
            parameters["stock_status"] = stockStatus.map { $0.filterString }
        }
        
        if let checkRecommendationStatus = checkRecommendationStatus, !checkRecommendationStatus.isEmpty {
            parameters["check_recommendation"] = checkRecommendationStatus.map { $0.filterString }
        }
        
        // Add optional dates formatted as "YYYY-MM-DD"
        if let startDate = startDate {
            parameters["start_date"] = startDate.toString(format: "YYYY-MM-dd", setTimeTo: "00:00:01")
        }
        
        if let endDate = endDate {
            parameters["end_date"] = endDate.toString(format: "YYYY-MM-dd", setTimeTo: "23:59:59")
        }
        
        if let isChecked = isChecked {
            parameters["is_checked"] = isChecked
        }
        
        if let stockAmount = stockAmount {
            parameters["stock_amount"] = stockAmount.filterString
        }

        networkService.request(
            urlString: PipelineEndpoint.getProductsSummary.urlString,
            method: .get,
            parameters: parameters,
            headers: [
                "Client-Id": clientID
            ],
            body: nil,
            completion: completion
        )
    }
    
    func getProductDetail(
        clientID: String = "",
        productID: String,
        completion: @escaping (Result<ProductDetailResponse, NetworkServiceError>) -> Void
    ) {
        networkService.request(
            urlString: PipelineEndpoint.getProductDetail.urlString,
            method: .get,
            parameters: [
                "product_unified_id": productID
            ],
            headers: ["Client-Id": clientID],
            body: nil,
            completion: completion
        )
    }
}

extension PipelineFetcher {
    func triggerPipelineAsync(
        clientID: String = ""
    ) async throws -> SuccessResponse<ProductInsightArrayResponse> {
        try await withCheckedThrowingContinuation { continuation in
            networkService.request(
                urlString: PipelineEndpoint.triggerPipeline.urlString,
                method: .get,
                parameters: [:],
                headers: ["Client-Id": clientID],
                body: nil
            ) { result in
                let normalized = self.normalizePipelineResult(result)
                
                switch normalized {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

private extension PipelineFetcher {
    func normalizePipelineResult(
        _ result: Result<SuccessResponse<ProductInsightArrayResponse>, NetworkServiceError>
    ) -> Result<SuccessResponse<ProductInsightArrayResponse>, NetworkServiceError> {
        switch result {
        case .success:
            return result
        case .failure(let error):
            guard case .decodingFailed(let underlying) = error else {
                return .failure(error)
            }
            
            let message = messageForPipelineFallback(from: underlying)
            if let data = try? ProductInsightArrayResponse(jsonArray: []) {
                let placeholder = SuccessResponse(
                    code: 202,
                    message: message,
                    data: data
                )
                return .success(placeholder)
            } else {
                return .failure(error)
            }
        }
    }
    
    func messageForPipelineFallback(from _: Error) -> String {
        "Pipeline triggered successfully. Data processing in progress."
    }
}


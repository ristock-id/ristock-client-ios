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
        completion: @escaping (Result<SuccessResponse<ProductInsightArrayResponse>, NetworkServiceError>) -> Void
    )
    
    func updateStatusStock(
        clientID: String,
        request: UpdateProductStatusArrayRequest,
        completion: @escaping (Result<SuccessResponse<UpdateProductStatusResponse>, NetworkServiceError>) -> Void
    )
}

final class PipelineFetcher: PipelineFetcherProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func get(
        clientID: String = "",
        completion: @escaping (Result<SuccessResponse<ProductInsightArrayResponse>, NetworkServiceError>) -> Void
    ) {
        networkService.request(
            urlString: PipelineEndpoint.get.urlString,
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
}

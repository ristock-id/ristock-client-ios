//
//  PipelineFetcher.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 21/10/25.
//

import Foundation

protocol PipelineFetcherProtocol: AnyObject {
//    func get(
//        completion: @escaping (Result<SuccessResponse<ProductInsightArrayResponse>, NetworkServiceError>) -> Void
//    )
    
//    func updateStatusStock(
//        request: UpdateProductStatusArrayRequest,
//        completion: @escaping (Result<SuccessResponse<UpdateProductStatusResponse>, NetworkServiceError>) -> Void
//    )
}

final class PipelineFetcher: PipelineFetcherProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
//    func get(
//        completion: @escaping (Result<SuccessResponse<ProductInsightArrayResponse>, NetworkServiceError>) -> Void
//    ) {
//        networkService.request(
//            urlString: PipelineEndpoint.get.urlString,
//            method: .get,
//            parameters: [:],
//            headers: [:],
//            body: nil,
//            completion: completion
//        )
//    }
//    
//    func updateStatusStock(
//        request: UpdateProductStatusArrayRequest,
//        completion: @escaping (Result<SuccessResponse<UpdateProductStatusResponse>, NetworkServiceError>) -> Void
//    ) {
//        
//        networkService.request(
//            urlString: PipelineEndpoint.updateStatusStock.urlString,
//            method: .post,
//            parameters: [:],
//            headers: [:],
//            body: request,
//            completion: completion
//        )
//    }
}

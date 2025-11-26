//
//  NotificationFetcher.swift
//  RiSTOCK-Client
//
//  Created by Rico Tandrio on 24/11/25.
//

import Foundation

struct UpdateDeviceTokenRequest: JSONEncodable {
    let clientDeviceToken: String
    
    private enum CodingKeys: String, CodingKey {
        case clientDeviceToken = "client_device_token"
    }
    
    init(clientDeviceToken: String) {
        self.clientDeviceToken = clientDeviceToken
    }
}

struct UpdateDeviceTokenData: JSONDecodable {
    let id: String?
    let name: String?
    let email: String?
    let deviceToken: String?
    let clientDeviceToken: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case email = "email"
        case deviceToken = "device"
        case clientDeviceToken = "client_device_token"
    }
}

typealias UpdateDeviceTokenResponse = SuccessResponse<UpdateDeviceTokenData>

protocol NotificationFetcherProtocol: AnyObject {
    func updateDeviceToken(
        clientID: String,
        deviceToken: String,
        completion: @escaping (Result<UpdateDeviceTokenResponse, NetworkServiceError>) -> Void
    )
}

final class NotificationFetcher: NotificationFetcherProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func updateDeviceToken(
        clientID: String = "",
        deviceToken: String,
        completion: @escaping (Result<UpdateDeviceTokenResponse, NetworkServiceError>) -> Void
    ) {
        let requestBody = UpdateDeviceTokenRequest(
            clientDeviceToken: deviceToken
        )
        
        networkService.request(
            urlString: NotificationEndpoint.updateDeviceToken.urlString,
            method: .post,
            parameters: [:],
            headers: ["Client-Id": clientID],
            body: requestBody,
            completion: completion
        )
    }
}

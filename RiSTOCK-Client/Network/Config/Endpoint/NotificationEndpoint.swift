//
//  NotificationEndpoint.swift
//  RiSTOCK-Client
//
//  Created by Rico Tandrio on 24/11/25.
//

import Foundation

enum NotificationEndpoint: EndpointProtocol {
    case updateDeviceToken
    
    var path: String {
        switch self {
        case .updateDeviceToken:
            return "user/device-token"
        }
    }
}

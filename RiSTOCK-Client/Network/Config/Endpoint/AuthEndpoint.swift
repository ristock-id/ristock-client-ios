//
//  AuthEndpoint.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 21/10/25.
//

import Foundation

enum AuthEndpoint: EndpointProtocol {
    case login
    case signUp
    case logout
    case me
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .signUp:
            return "/auth/register"
        case .logout:
            return "/auth/logout"
        case .me:
            return "/auth/me"
        }
    }
}

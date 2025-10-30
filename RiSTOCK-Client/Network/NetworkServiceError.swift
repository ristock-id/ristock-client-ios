//
//  NetworkServiceError.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 19/10/25.
//

import Foundation

enum NetworkServiceError: Error {
    case invalidURL
    case bodyParsingFailed
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case statusCode(Int)
    case noInternetConnection
}

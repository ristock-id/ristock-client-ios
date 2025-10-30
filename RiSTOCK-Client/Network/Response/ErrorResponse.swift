//
//  ErrorResponse.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 21/10/25.
//

struct ErrorResponse: JSONDecodable {
    let code: Int
    let error: String
}

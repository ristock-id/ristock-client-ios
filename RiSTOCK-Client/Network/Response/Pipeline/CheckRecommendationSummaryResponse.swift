//
//  CheckRecommendationSummaryResponse.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 12/11/25.
//

struct CheckRecommendationSummaryResponse:  JSONDecodable {
    let low: Int
    let medium: Int
    let high: Int
    let total: Int
    
    enum CodingKeys: String, CodingKey {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case total
    }
}

struct Summary: JSONDecodable {
    let low: Int
    let medium: Int
    let high: Int
    let total: Int
    
    enum CodingKeys: String, CodingKey {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case total
    }

}

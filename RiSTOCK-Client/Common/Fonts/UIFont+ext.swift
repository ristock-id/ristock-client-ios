//
//  UIFont+ext.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 19/10/25.
//

import Foundation
import SwiftUI
import UIKit

extension UIFont {
    enum FontFamily: String {
        case primary = "Inter"
    }
    
    static func resolveFontName(for family: FontFamily, weight: UIFont.Weight) -> String {
        switch (family, weight) {
        case (.primary, .regular): 
            return "Inter-Regular"
        case (.primary, .semibold):
            return "Inter-SemiBold"
        case (.primary, .bold):
            return "Inter-Bold"
        default:
            return "\(family.rawValue)-Regular"
        }
    }
    
    
}

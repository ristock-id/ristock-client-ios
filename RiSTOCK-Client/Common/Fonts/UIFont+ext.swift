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
    
    static func resolveFontName(
        for family: FontFamily,
        weight: UIFont.Weight
    ) -> String {
        switch (family, weight) {
        case (.primary, .regular): 
            return "Inter-Black"
        case (.primary, .semibold):
            return "Inter-SemiBold"
        case (.primary, .bold):
            return "Inter-Bold"
        case (.primary, .medium):
            return "Inter-Medium"
        case (.primary, .thin):
            return "Inter-Thin"
        case (.primary, .light):
            return "Inter-Light"
        default:
            return "\(family.rawValue)-Regular"
        }
    }
    
    
}

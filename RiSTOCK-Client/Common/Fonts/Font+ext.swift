//
//  Font+ext.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 19/10/25.
//

import Foundation
import SwiftUI

extension Font {
    static func customFont(
        size: CGFloat,
        family: UIFont.FontFamily = .primary,
        weight: UIFont.Weight = .regular
    ) -> Font {
        return Font.custom(UIFont.resolveFontName(for: family, weight: weight), size: size)
    }
}

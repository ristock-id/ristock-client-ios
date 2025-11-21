//
//  ProductRowSkeleton.swift
//  RiSTOCK-Client
//
//  Created by Rico Tandrio on 21/11/25.
//

import SwiftUI

struct ProductRowSkeleton: View {
    var height: CGFloat = 80
    
    var body: some View {
        HStack(spacing: 12) { }
            .padding(.horizontal)
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .shimmering()
    }
}

// MARK: Preview
struct ProductRowSkeleton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            Text("Loading Products...")
                .font(.headline)
            
            ForEach(0..<4) { _ in
                ProductRowSkeleton()
                Divider()
            }
        }
    }
}

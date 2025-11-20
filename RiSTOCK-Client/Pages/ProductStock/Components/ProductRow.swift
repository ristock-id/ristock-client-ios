//
//  ProductRow.swift
//  RiSTOCK-Client
//
//  Created by Akbar Febry on 15/11/25.
//

import SwiftUI

struct ProductRow: View {
    let index: Int
    @Binding var product: ProductSummaryUI
    @Binding var isPopoverPresented: Bool
    
    var body: some View {
        HStack(alignment: .center) {
            Text("\(index)")
                .font(.customFont(size: 15, weight: .regular))
                .padding(.leading, 13)
            
            Text(product.name)
                .font(.customFont(size: 15, weight: .regular))
                .padding(.horizontal, 13)
            
            Spacer()
            
            StockStatusMenu(product: $product,
                            isPopoverPresented: $isPopoverPresented)
        }
        .padding(.leading, 12)
        .padding(.trailing, 30)
        .padding(.vertical, 13)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Token.gray500.swiftUIColor, lineWidth: 1)
        )
        .cornerRadius(8)
    }
}

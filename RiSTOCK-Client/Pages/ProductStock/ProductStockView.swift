//
//  ProductStockView.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 19/10/25.
//

import SwiftUI

struct ProductStockView: View {
    @StateObject var viewModel: ProductStockViewModel
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
                    .padding()
            } else {
                VStack {
                    ForEach(viewModel.products) { product in
                        HStack {
                            Text(product.name)
                                .font(.headline)
                            Spacer()
                            Text("Stock: \(String(describing: product.stockStatus?.rawValue))")
                                .font(.subheadline)
                        }
                        .padding()
                        Divider()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .frame(width: 1920, height: 600)
}

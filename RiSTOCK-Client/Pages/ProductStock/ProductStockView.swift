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
                    ForEach(viewModel.products.indices, id: \.self) { index in
                        HStack {
                            Text(viewModel.products[index].name)
                                .font(.headline)
                            Spacer()
                            
                            StockStatusMenu(
                                product: $viewModel.products[index],
                                fetchStatusUpdate: viewModel.fetchUpdateStockStatus
                            )
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

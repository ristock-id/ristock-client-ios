//
//  ProductStockView.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 19/10/25.
//

import SwiftUI

struct StockInfoCardView: View {
    let status: StockStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("123")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text(status.rawValue)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Token.primary500.swiftUIColor)
                .overlay(
                    Image(systemName: "circle.grid.3x3.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Token.primary500.swiftUIColor)
                        .padding([.top, .trailing], 8)
                    , alignment: .topTrailing
                )
        )
    }
}

// MARK: - 3. The Main Static View

struct ProductStockView: View {
    @StateObject var viewModel: ProductStockViewModel
    @State private var isPopoverPresented: [String: Bool] = [:]
    
    @State var isChecked: Bool? = nil
    
    @FocusState var isSearchFieldFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    Text("Cek Stok Produk")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(Token.primary500.swiftUIColor)
                    
                    Spacer()
                    
                    Button {
                        viewModel.logout()
                    } label: {
                        Image(systemName: "arrow.right.square")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.top, 50)
                
                SearchAndFilter(
                    searchText: $viewModel.searchText,
                    isChecked: $viewModel.isChecked,
                    isSearchFieldFocused: $isSearchFieldFocused
                )
                
                if !isSearchFieldFocused {
                    headerSection()
                        .animation(.bouncy, value: !isSearchFieldFocused)
                }
                
                productListSection()
                    .animation(.bouncy, value: !isSearchFieldFocused)
            }
            .background(Token.white.swiftUIColor)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                isSearchFieldFocused = false
            }
        }
        .refreshable {
            viewModel.resetPageAndFetch()
        }
    }
    
    // MARK: - Header Section
    @ViewBuilder
    private func headerSection() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            
            HStack(spacing: 10) {
                ForEach(StockStatus.allCases, id: \.self) { status in
                    StockInfoCardView(status: status)
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Product List Section
    @ViewBuilder
    private func productListSection() -> some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.products.indices, id: \.self) { index in
                ProductRowView(
                    index: index + 1,
                    name: viewModel.products[index].name
                )
                .onAppear {
                    let thresholdIndex = viewModel.products.count - 5
                    
                    let isNearEnd = index >= thresholdIndex
                    
                    if isNearEnd {
                        viewModel.loadNextPage()
                    }
                }
            }
            
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            }
        }
        .padding(.top)
    }
}

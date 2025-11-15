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

struct ProductRowView: View {
    let index: Int
    let name: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text("\(index)")
                .font(.subheadline)
                .frame(width: 20, alignment: .leading)
                .padding(.top, 4)
            
            Text(name)
                .font(.subheadline)
                .lineLimit(2)
                .padding(.horizontal, 8)
            
            Spacer()
            
            // Static Stock Menu Appearance
            HStack {
                Text("Stok")
                    .font(.caption)
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .foregroundColor(.black)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}


// MARK: - 3. The Main Static View

struct ProductStockView: View {
    @StateObject var viewModel: ProductStockViewModel
    @State private var isHovered: Bool = false
    
    @State var isChecked: Bool? = nil
    
    @FocusState var isSearchFieldFocused: Bool
    
    var body: some View {
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
        .background(Color.gray.opacity(0.05))
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
            isSearchFieldFocused = false
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
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.products.indices, id: \.self) { index in
                        ProductRowView(
                            index: index + 1,
                            name: viewModel.products[index].name
                        )
                    }
                }
                .padding(.top)
            }
        }
    }
}

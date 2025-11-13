//
//  ProductStockView.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 19/10/25.
//

import SwiftUI

//struct ProductStockView: View {
//    @StateObject var viewModel: ProductStockViewModel
//    @State private var isHovered: Bool = false
//    
//    var body: some View {
//        ScrollView {
//            if viewModel.isLoading {
//                ProgressView()
//                    .progressViewStyle(CircularProgressViewStyle())
//                    .scaleEffect(2)
//                    .padding()
//            } else {
//                VStack {
//                    ForEach(viewModel.products.indices, id: \.self) { index in
//                        HStack {
//                            Text(viewModel.products[index].name)
//                                .font(.headline)
//                            Spacer()
//                            
//                            StockStatusMenu(
//                                product: $viewModel.products[index],
//                                fetchStatusUpdate: viewModel.fetchUpdateStockStatus,
//                                isHovered: $isHovered
//                            )
//                        }
//                        .padding()
//                        Divider()
//                    }
//                }
//            }
//        }
//    }
//}

// MARK: - 2. Component Helpers (No State/Bindings)

struct StaticStockInfoCardView: View {
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

struct StaticProductRowView: View {
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

    var body: some View {
        VStack(spacing: 0) {
            headerSection()
            searchAndFilterSection()
            productListSection()
        }
        .background(Color.gray.opacity(0.05))
        .edgesIgnoringSafeArea(.all)
    }

    // MARK: - Header Section
    @ViewBuilder
    private func headerSection() -> some View {
        VStack(alignment: .leading, spacing: 15) {
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
            
            HStack(spacing: 10) {
                ForEach(StockStatus.allCases, id: \.self) { status in
                    StaticStockInfoCardView(status: status)
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, 50)
        .padding(.bottom, 10)
    }

    // MARK: - Search & Filter Section
    @ViewBuilder
    private func searchAndFilterSection() -> some View {
        VStack(spacing: 15) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                Text("Search produk..")
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
            
            // Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(StockStatus.low.accentColor.swiftUIColor)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                    
                    ForEach(StockStatus.allCases, id: \.self) { status in
                        Text(status.rawValue)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Token.primary500.swiftUIColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Token.primary500.swiftUIColor)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                    )
                            )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 5)
            }
        }
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 3)
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
                        StaticProductRowView(
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


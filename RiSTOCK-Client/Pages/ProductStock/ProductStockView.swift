//
//  ProductStockView.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 19/10/25.
//

import SwiftUI

struct StockInfoCardView: View {
    @State private var isActive: Bool = false
    
    let status: StockStatus
    let count: Int
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    path.move(to: CGPoint(x: width * 0.65, y: 0))
                    
                    path.addCurve(
                        to: CGPoint(x: width * 0.7, y: height * 0.55),
                        control1: CGPoint(x: width * 0.55, y: height * 0.2),
                        control2: CGPoint(x: width * 0.5, y: height * 0.3)
                    )
                    
                    path.addCurve(
                        to: CGPoint(x: width * 0.7, y: height),
                        control1: CGPoint(x: width * 0.8, y: height * 0.7),
                        control2: CGPoint(x: width * 0.8, y: height * 0.8)
                    )
                    
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.addLine(to: CGPoint(x: width, y: 0))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            isActive ? Token.primary400.swiftUIColor : Token.primary100.swiftUIColor,
                            isActive ? Token.primary400.swiftUIColor : Token.primary100.swiftUIColor
                        ]),
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                )
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(count)")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(isActive ? Token.white.swiftUIColor : Token.primary700.swiftUIColor)
                    
                    Spacer()
                    
                    status.icon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 24, maxHeight: 24)
                }
                .padding(.vertical, 2)
                
                Text(status.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isActive ? Token.white.swiftUIColor : Token.primary700.swiftUIColor)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            isActive.toggle()
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isActive ? Token.primary600.swiftUIColor : Token.primary50.swiftUIColor)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
                StockInfoCardView(status: .out, count: viewModel.countCheckNow.updated)
                StockInfoCardView(status: .low, count: viewModel.countCheckSoon.updated)
                StockInfoCardView(status: .safe, count: viewModel.countCheckPeriodically.updated)
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

#Preview("With Mock Data") {
    let mockViewModel = ProductStockViewModel(
        pipelineFetcher: PipelineFetcher(),
        deviceId: "mock-device-id"
    )
    
    mockViewModel.products = [
        ProductSummaryUI(
            id: "1",
            index: 0,
            name: "Product A",
            checkRecommendation: .now,
            stockStatus: .out,
            updatedAt: Date(),
            analysisUpdatedAt: Date()
        ),
        ProductSummaryUI(
            id: "2",
            index: 1,
            name: "Product B",
            checkRecommendation: .soon,
            stockStatus: .low,
            updatedAt: Date(),
            analysisUpdatedAt: Date()
        ),
        ProductSummaryUI(
            id: "3",
            index: 2,
            name: "Product C",
            checkRecommendation: .periodically,
            stockStatus: .safe,
            updatedAt: Date(),
            analysisUpdatedAt: Date()
        )
    ]
    mockViewModel.countCheckNow = CheckCount(updated: 420, total: 5)
    mockViewModel.countCheckSoon = CheckCount(updated: 999, total: 10)
    mockViewModel.countCheckPeriodically = CheckCount(updated: 999, total: 15)
    
    return ProductStockView(viewModel: mockViewModel)
}

#Preview("Loading State") {
    let mockViewModel = ProductStockViewModel(
        pipelineFetcher: PipelineFetcher(),
        deviceId: "mock-device-id"
    )
    mockViewModel.isLoading = true
    
    return ProductStockView(viewModel: mockViewModel)
}

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
        .overlayPreferenceValue(ProductRowFramePreferenceKey.self) { preferences in
            overlayContent(preferences: preferences)
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
        LazyVStack(spacing: 12) {
            ForEach(viewModel.products.indices, id: \.self) { index in
                ProductRow(
                    index: index + 1,
                    product: $viewModel.products[index],
                    isPopoverPresented: bindingForPopoverState(of: viewModel.products[index].id)
                )
                .onAppear {
                    let thresholdIndex = max(viewModel.products.count - 5, 0)
                    if index >= thresholdIndex {
                        viewModel.loadNextPage()
                    }
                }
            }
            
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 40)
        .padding(.horizontal)
    }
    
    private func bindingForPopoverState(of productId: String) -> Binding<Bool> {
        Binding(
            get: {
                isPopoverPresented[productId] ?? false
            },
            set: { newValue in
                if newValue {
                    isPopoverPresented = [productId: true]
                } else {
                    isPopoverPresented.removeValue(forKey: productId)
                }
            }
        )
    }
    
    @ViewBuilder
    private func overlayContent(preferences: [String: Anchor<CGRect>]) -> some View {
        if let activeProductId = activePopoverProductId,
           let selectedProduct = viewModel.products.first(where: { $0.id == activeProductId }) {
            StockStatusOverlay(
                preferences: preferences,
                activeProductId: activeProductId,
                selectedStatus: selectedProduct.stockStatus,
                onBackgroundTap: dismissPopovers,
                onStatusSelected: { status in
                    viewModel.updateStockStatus(for: activeProductId, to: status) { result in
                        switch result {
                        case .success:
                            dismissPopover(for: activeProductId)
                        case .failure(let error):
                            print("Failed to update status for \(activeProductId): \(error)")
                        }
                    }
                }
            )
        }
    }
    
    private var activePopoverProductId: String? {
        isPopoverPresented.first(where: { $0.value })?.key
    }
    
    private func dismissPopovers() {
        isPopoverPresented.removeAll()
    }
    
    private func dismissPopover(for productId: String) {
        isPopoverPresented.removeValue(forKey: productId)
    }
}

struct ProductRowFramePreferenceKey: PreferenceKey {
    static var defaultValue: [String: Anchor<CGRect>] = [:]
    
    static func reduce(value: inout [String: Anchor<CGRect>], nextValue: () -> [String: Anchor<CGRect>]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

private struct StockStatusOverlay: View {
    let preferences: [String: Anchor<CGRect>]
    let activeProductId: String
    let selectedStatus: StockStatus?
    let onBackgroundTap: () -> Void
    let onStatusSelected: (StockStatus) -> Void
    
    var body: some View {
        GeometryReader { proxy in
            if let anchor = preferences[activeProductId] {
                let frame = proxy[anchor]
                
                ZStack(alignment: .topLeading) {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            onBackgroundTap()
                        }
                    
                    StatusSelectionList(
                        onButtonClick: onStatusSelected,
                        selectedStatus: selectedStatus
                    )
                    .fixedSize()
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .offset(
                        x: frame.minX - 25,
                        y: frame.minY - 40
                    )
                }
            }
        }
    }
}

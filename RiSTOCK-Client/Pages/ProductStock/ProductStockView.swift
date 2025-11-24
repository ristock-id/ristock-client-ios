//
//  ProductStockView.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 19/10/25.
//

import SwiftUI

struct StockInfoCardView: View {
    @State private var isActive: Bool = false
    
    let status: CheckRecommendationStatus
    let count: Int
    var callback: (Bool, CheckRecommendationStatus) -> Void
    
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
                        .font(.customFont(size: 26, weight: .bold))
                        .foregroundColor(isActive ? Token.white.swiftUIColor : Token.primary700.swiftUIColor)
                    
                    Spacer()
                    
                    status.icon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 24, maxHeight: 24)
                }
                .padding(.vertical, 2)
                
                Text(status.rawValue)
                    .font(.customFont(size: 12, weight: .medium))
                    .foregroundColor(isActive ? Token.white.swiftUIColor : Token.primary700.swiftUIColor)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            isActive.toggle()
            callback(isActive, status)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isActive ? Token.primary600.swiftUIColor : Token.primary50.swiftUIColor)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 3. The Main Static View

struct ProductStockView: View {
    @StateObject var viewModel: ProductStockViewModel
    
    @FocusState var isSearchFieldFocused: Bool
    
    @Environment(\.accessibilityReduceMotion) var reduceMotion: Bool
    
    // TODO: Refactor alert presentation to ViewModel
    @State var isLogoutAlertPresented: Bool = false
    @State private var isPopoverPresented: [String: Bool] = [:]
    @State var isChecked: Bool? = nil
    
    var body: some View {
        Group {
            VStack(spacing: 0) {
                HStack {
                    Text("Cek Stok Produk")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(Color.black)
                    
                    Spacer()
                    
                    Button {
                        isLogoutAlertPresented = true
                    } label: {
                        Image(systemName: "arrow.right.square")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.top, 80)
                
                SearchAndFilter(
                    searchText: $viewModel.searchText,
                    isChecked: $viewModel.isChecked,
                    isSearchFieldFocused: $isSearchFieldFocused
                )
                
                if viewModel.searchText.isEmpty || !isSearchFieldFocused {
                    headerSection()
                        .animation(reduceMotion ? nil : .bouncy, value: !isSearchFieldFocused)
                }
                
                Spacer().frame(height: 20)
                
                productListSection()
                    .animation(reduceMotion ? nil : .bouncy, value: !isSearchFieldFocused)
                    .refreshable {
                        viewModel.resetPageAndFetch()
                    }
                    .background(Token.white.swiftUIColor)
            }
            .background(Token.white.swiftUIColor)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                isSearchFieldFocused = false
            }
        }
        .overlayPreferenceValue(ProductRowFramePreferenceKey.self) { preferences in
            overlayContent(preferences: preferences)
        }
        .alertRistock(
            isPresented: $isLogoutAlertPresented,
            title: "Keluar Akun?",
            message: "Anda bisa login kembali saat mengecek di Hand Phone nanti.",
            image: Image(uiImage: RiSTOCKIcon.logoutIcon.image),
            onConfirm: { viewModel.logout() },
            onCancel: { isLogoutAlertPresented = false }
        )
    }
    
    // TODO: Refactor this to ViewModel
    private func selectCheckRecommendationFilter(isActive: Bool, checkRecommendation: CheckRecommendationStatus) {
        if isActive {
            viewModel.selectedCheckRecommendationFilter.insert(checkRecommendation)
        } else {
            viewModel.selectedCheckRecommendationFilter.remove(checkRecommendation)
        }
    }
    
    // MARK: - Header Section
    @ViewBuilder
    private func headerSection() -> some View {
        HStack(spacing: 10) {
            if viewModel.products.isEmpty && viewModel.isLoading {
                ProductRowSkeleton().cornerRadius(8)
                ProductRowSkeleton().cornerRadius(8)
                ProductRowSkeleton().cornerRadius(8)
            } else {
                ProductInsightHeader(viewModel: viewModel)
                    .modifier(CardBackgroundModifier())
            }
        }
        .padding(.horizontal)
        .padding(.top, 20)
        .frame(maxHeight: 77)
    }

    // MARK: - Product List Section
    @ViewBuilder
    private func productListSection() -> some View {
        ScrollView {
            if viewModel.products.isEmpty && viewModel.isLoading {
                ForEach(0..<10, id: \.self) {_ in
                    ProductRowSkeleton().cornerRadius(8)
                }
                .background(Token.white.swiftUIColor)
            } else {
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
                    }
                    
                    Spacer().frame(height: 20)
                }
                .background(Token.white.swiftUIColor)
            }
        }
        .background(Token.white.swiftUIColor)
        .scrollIndicators(.hidden)
        .padding(.horizontal)
        .padding(.top, 5)
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

// MARK: Preview
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
        deviceId: "e2eb2658-3a31-4566-b2a9-7b77c1352fc8"
    )
    mockViewModel.isLoading = true
    
    return ProductStockView(viewModel: mockViewModel)
}

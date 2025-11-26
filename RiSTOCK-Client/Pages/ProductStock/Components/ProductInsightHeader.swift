//
//  CardComponent.swift
//  RiSTOCK-Client
//
//  Created by Andrea Octaviani on 24/11/25.
//

import SwiftUI

struct ProductInsightHeader: View {
    @ObservedObject var viewModel: ProductStockViewModel
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                productsInsightCardSkeleton()
            } else {
                stockStatusCard()
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    @ViewBuilder
    private func stockStatusCard() -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Status Stok")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Token.white.swiftUIColor)
                
                Text("\(viewModel.totalStockFilled)")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(Token.white.swiftUIColor)
            }
            .padding(.vertical, 16)
            
            VStack(alignment: .leading, spacing: 10) {
                SegmentedBar(segments: [
                    BarSegment(
                        percentage: viewModel.safePct,
                        color: Token.success300.swiftUIColor
                    ),
                    
                    BarSegment(
                        percentage: viewModel.lowPct,
                        color: Token.warning300.swiftUIColor
                    ),
                    
                    BarSegment(
                        percentage: viewModel.outPct,
                        color: Token.error300.swiftUIColor
                    )
                ])
                .frame(height: 6)
                .background(viewModel.totalStockFilled > 0 ? Token.transparent.swiftUIColor : Token.gray200.swiftUIColor)
                .cornerRadius(16)
                .padding(.bottom, 12)
                .padding(.trailing, 1)
                
                HStack(spacing: 10) {
                    RowIconText(
                        color: Token.success300.swiftUIColor,
                        text: "aman",
                        number: viewModel.safeCount
                    )
                    
                    RowIconText(
                        color: Token.warning300.swiftUIColor,
                        text: "menipis",
                        number: viewModel.lowCount
                    )
                    
                    RowIconText(
                        color: Token.error300.swiftUIColor,
                        text: "habis",
                        number: viewModel.outCount
                    )
                }
                .foregroundColor(Token.white.swiftUIColor)
            }
            .padding(.trailing, 16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
//        .modifier(CardBackgroundModifier())
    }
    
    @ViewBuilder
    private func productsInsightCardSkeleton() -> some View {
        HStack {
            ProductRowSkeleton(height: 100)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .modifier(CardBackgroundModifier())
    }
}

struct CardBackgroundModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        
        if #available(iOS 26.0, *) {
            // --- STYLE LIQUID GLASS (iOS 26) ---
            content
                .glassEffect(.clear, in: .rect(cornerRadius: 16))
        } else {
            // Logic fallback untuk iOS lama (Solid)
            content
                .background(Color._143_A_6_D)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

//MARK: - Preview
#if DEBUG
struct ProductInsightHeader_Previews: PreviewProvider {
    static var previews: some View {
        ProductInsightHeader(viewModel: ProductStockViewModel(deviceId: ""))
            .frame(maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [
                        Token.primary300.swiftUIColor, // Warna lebih terang di atas
                        Token.primary600.swiftUIColor  // Warna utama di bawah
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
            )
        )
        .previewDisplayName("Full Screen Preview")
    }
}
#endif

//
//  StockStatusMenu.swift
//  RiSTOCK-Client
//
//  Created by Rico Tandrio on 23/10/25.
//

import SwiftUI
import Combine

// MARK: - Stock Status Menu (Main View)
struct StockStatusMenu: View {
    @Binding var product: ProductSummaryUI
    @Binding var isPopoverPresented: Bool
    
    var body: some View {
        Button {
            isPopoverPresented.toggle()
        } label: {
            StockStatusTag(
                status: product.stockStatus,
                isPresented: $isPopoverPresented,
            )
        }
        .buttonStyle(.plain)
        .background(
            Color.clear.anchorPreference(
                key: ProductRowFramePreferenceKey.self,
                value: .bounds
            ) { [product.id: $0] }
        )
    }
}

// MARK: - Stock Status Tag (The Popover Trigger)
private struct StockStatusTag: View {
    let status: StockStatus?
    @Binding var isPresented: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Text(status?.filterString.capitalized ?? "Stok")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(status?.accentColor.swiftUIColor ?? Token.gray500.swiftUIColor)
                .lineLimit(1)
            
            Image(systemName: "chevron.down")
                .resizable()
                .frame(width: 12, height: 6)
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(status?.accentColor.swiftUIColor ?? Token.gray500.swiftUIColor)
                .rotationEffect(.degrees(isPresented ? 180 : 0))
                .animation(.easeInOut, value: isPresented)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(status?.backgroundColor.swiftUIColor ?? Token.gray50.swiftUIColor)
                RoundedRectangle(cornerRadius: 8)
                    .stroke(status?.backgroundColor.swiftUIColor ?? Token.gray50.swiftUIColor)
            }
        )
        .contentShape(RoundedRectangle(cornerRadius: 8))
    }
}


// MARK: - Popover Content View
struct StatusSelectionList: View {
    var onButtonClick: ((StockStatus) -> Void)? = nil
    var selectedStatus: StockStatus?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(StockStatus.allCases, id: \.self) { statusOption in
                
                Button {
                    onButtonClick?(statusOption)
                } label: {
                    HStack {
                        StatusSelectionIndicator(
                            isSelected: statusOption == selectedStatus,
                            strokeColor: Token.gray500.swiftUIColor,
                            fillColor: Token.primary600.swiftUIColor
                        )
                        .frame(width: 18, height: 18)
                        .padding(.trailing, 5)
                        
                        Text(statusOption.filterString.capitalized)
                            .font(.system(size: 15, weight: .regular))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .cornerRadius(6)
            }
        }
        .padding(6)
        .background(Color.white)
        .cornerRadius(10)
        .offset(x:26, y: 77)
    }
}

private struct StatusSelectionIndicator: View {
    let isSelected: Bool
    let strokeColor: Color
    let fillColor: Color
    
    var body: some View {
        Circle()
            .stroke(strokeColor, lineWidth: 2)
            .overlay(
                Circle()
                    .fill(Token.primary600.swiftUIColor)
                    .opacity(isSelected ? 1 : 0)
                    .overlay(
                        Circle()
                            .fill(Token.white.swiftUIColor)
                            .padding(5)
                            .opacity(isSelected ? 1 : 0)
                    )
            )
    }
}

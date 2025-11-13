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
    @Binding var product: Product
    var fetchStatusUpdate: ((String, StockStatus, @escaping (() -> Void)) -> Void)? = nil
    
    @State private var isPopoverPresented = false // State to manage popover visibility
    
    @Binding var isHovered: Bool
    
    var body: some View {
        // The Tag itself acts as the button trigger
        Button {
            isPopoverPresented.toggle()
        } label: {
            StockStatusTag(
                status: {
                    if let analysisUpdatedAt = product.analysisUpdatedAt {
                        if product.stockStatus != nil && product.lastUpdated < analysisUpdatedAt {
                            return nil
                        }
                    }
                    return product.stockStatus
                }(),
                isPresented: $isPopoverPresented,
                isHovered: $isHovered
            )
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isPopoverPresented, arrowEdge: .bottom) {
            StatusSelectionList(
                onButtonClick: { selectedStatus in
                    fetchStatusUpdate?(
                        product.id,
                        selectedStatus,
                        {
                            product.stockStatus = selectedStatus
                            product.lastUpdated = Date()
                        }
                    )
                },
                isPresented: $isPopoverPresented
            )
            .ignoresSafeArea()
            .fixedSize()
        }
    }
}

// MARK: - Stock Status Tag (The Popover Trigger)
private struct StockStatusTag: View {
    let status: StockStatus?
    @Binding var isPresented: Bool
    @Binding var isHovered: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Text(status?.rawValue ?? "Update Stock")
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
                    .stroke(isHovered ? status?.accentColor.swiftUIColor ?? Token.gray500.swiftUIColor : Token.transparent.swiftUIColor, lineWidth: 1)
            }
        )
        .contentShape(RoundedRectangle(cornerRadius: 8))
    }
}


// MARK: - Popover Content View
private struct StatusSelectionList: View {
    var onButtonClick: ((StockStatus) -> Void)? = nil
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(StockStatus.allCases, id: \.self) { statusOption in
                
                Button {
                    onButtonClick?(statusOption)
                    isPresented = false
                } label: {
                    HStack {
                        Image(uiImage: RiSTOCKIcon.circleEmpty.image)
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding(.trailing, 5)
                        
                        Text(statusOption.rawValue)
                            .font(.system(size: 16, weight: .regular))
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
    }
}

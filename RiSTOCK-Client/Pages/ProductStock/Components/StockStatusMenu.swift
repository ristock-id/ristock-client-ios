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
    
    var body: some View {
        // The Tag itself acts as the button trigger
        Button {
            isPopoverPresented.toggle()
        } label: {
            StockStatusTag(
                status: product.stockStatus,
                isPresented: $isPopoverPresented
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
    
    var body: some View {
        HStack(spacing: 4) {
            Text(status?.rawValue ?? "Status Stok")
                .font(.system(size: 16, weight: .regular))
            
            Image(systemName: "chevron.down")
                .resizable()
                .frame(width: 12, height: 6)
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(Color.gray)
                .rotationEffect(.degrees(isPresented ? 180 : 0))
                .animation(.easeInOut, value: isPresented)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray)
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black, lineWidth: 1)
                
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
                        Image(systemName: "circle.fill")
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

//
//  SearchAndFilter.swift
//  RiSTOCK-Client
//
//  Created by Rico Tandrio on 14/11/25.
//

import Foundation
import SwiftUI

// MARK: - SearchAndFilter View
struct SearchAndFilter: View {
    // MARK: Properties Binding
    @Binding var searchText: String
    @Binding var isChecked: Bool?
    @Binding var selectedStockStatusFilter: Set<StockStatus>
    
    @FocusState.Binding var isSearchFieldFocused: Bool
    
    // MARK: State Properties
    @State private var isFilterPresented: Bool = false {
        didSet {
            if isFilterPresented {
                isCheckedForFilter = isChecked
                selectedStockStatusForFilter = selectedStockStatusFilter
            }
        }
    }
    
    @State private var isCheckedForFilter: Bool? = nil
    @State private var selectedStockStatusForFilter: Set<StockStatus> = []
    
    @State private var showTrailingButton = true
    
    @Environment(\.accessibilityReduceMotion) var reduceMotion: Bool

    var body: some View {
        HStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Token.gray500.swiftUIColor)
                
                    TextField("", text: $searchText).placeholder(when: searchText.isEmpty) {
                        Text("Search produk..")
                            .font(.customFont(size: 13, weight: .regular))
                            .foregroundStyle(Token.gray500.swiftUIColor)
                    }
                    .disableAutocorrection(true)
                    .focused($isSearchFieldFocused)
                    .foregroundColor(Token.black.swiftUIColor)
                    .animation(.bouncy, value: isSearchFieldFocused)
                
                Spacer()
                
                if isSearchFieldFocused {
                    Button {
                        clearSearchIsTapped()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Token.gray200.swiftUIColor)
                    }
                    .buttonStyle(.plain)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Token.gray0.swiftUIColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.75), value: isSearchFieldFocused)
            .animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.75), value: showTrailingButton)

            if showTrailingButton {
                if isSearchFieldFocused {
                    Button {
                        cancelSearchIsTapped()
                    } label: {
                        Text("Cancel")
                            .font(.customFont(size: 13, weight: .medium))
                            .foregroundColor(Token.gray500.swiftUIColor)
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    Button {
                        filterButtonIsTapped()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(isChecked == nil  && selectedStockStatusFilter.isEmpty ? Token.gray500.swiftUIColor : Token.primary50.swiftUIColor)
                            .frame(width: 40, height: 40)
                            .background(isChecked == nil && selectedStockStatusFilter.isEmpty ? Token.gray50.swiftUIColor: Token.primary500.swiftUIColor)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.clear)
        .sheet(isPresented: $isFilterPresented) {
            filterSheet()
                .presentationDetents([.fraction(0.6)])
        }
        .onChange(of: isSearchFieldFocused) { _, focused in
            if focused {
                // Step 1: expand immediately
                withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.75)) {
                    showTrailingButton = false
                }
                // Step 2: show Cancel slightly after (staged)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.75)) {
                        showTrailingButton = true
                    }
                }
            } else {
                // Reverse sequence
                withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.75)) {
                    showTrailingButton = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.75)) {
                        showTrailingButton = true
                    }
                }
            }
        }
    }
    
    // MARK: Action Functions
    func cancelSearchIsTapped() {
        isSearchFieldFocused = false
    }
    
    func clearSearchIsTapped() {
        searchText = ""
    }
    
    func filterButtonIsTapped() {
        isFilterPresented.toggle()
    }
    
    func filterSheetButtonRemoveFilterTapped() {
        isChecked = nil
        isCheckedForFilter = nil
        selectedStockStatusFilter = []
        selectedStockStatusForFilter = []
        isFilterPresented = false
    }
    
    func filterSheetButtonApplyFilterTapped() {
        isChecked = isCheckedForFilter
        selectedStockStatusFilter = selectedStockStatusForFilter
        isFilterPresented = false
    }
    
    
    // MARK: View Builder Functions
    @ViewBuilder
    func filterSheet() -> some View {
        VStack(spacing: 0) {
            
            VStack(spacing: 16) {
                Rectangle()
                    .frame(width: 40, height: 5)
                    .background(Color(.systemGray5))
                    .cornerRadius(2.5)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 20)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text("Input Stok")
                        .font(.customFont(size: 15, weight: .semibold))
                        .padding(.top, 8)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 0) {
                    
                        StockInputOptionRow(
                            name: "Sudah input stok",
                            inputStatusValue: true,
                            selectedStockInputStatus: $isCheckedForFilter
                        )
                        
                        StockInputOptionRow(
                            name: "Perlu input stok",
                            inputStatusValue: false,
                            selectedStockInputStatus: $isCheckedForFilter
                        )
                        
                    }
                    
                    Text("Status Stok")
                        .font(.customFont(size: 15, weight: .semibold))
                        .padding(.top, 8)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 0) {
                    
                        StockStatusOptionRow(
                            name: "Aman",
                            statusStock: StockStatus.safe,
                            selectedStockStatusSet: $selectedStockStatusForFilter
                        )
                        
                        StockStatusOptionRow(
                            name: "Menipis",
                            statusStock: StockStatus.low,
                            selectedStockStatusSet: $selectedStockStatusForFilter
                        )
                        
                        StockStatusOptionRow(
                            name: "Habis",
                            statusStock: StockStatus.out,
                            selectedStockStatusSet: $selectedStockStatusForFilter
                        )
                        
                    }
                    
                }
                .padding(.horizontal)
            }
                    
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    Button("Hapus") {
                        filterSheetButtonRemoveFilterTapped()
                    }
                    .frame(maxWidth: .infinity)
                    .font(.customFont(size: 15, weight: .medium))
                    .padding(.vertical, 12)
                    .background(Token.primary50.swiftUIColor)
                    .foregroundColor(Token.primary500.swiftUIColor)
                    .cornerRadius(100)
                    
                    Button("Pakai") {
                        filterSheetButtonApplyFilterTapped()
                    }
                    .frame(maxWidth: .infinity)
                    .font(.customFont(size: 15, weight: .medium))
                    .padding(.vertical, 12)
                    .background(Token.primary500.swiftUIColor)
                    .foregroundColor(Token.white.swiftUIColor)
                    .cornerRadius(100)
                }
            }
            .padding([.horizontal, .bottom])
            .background(Token.white.swiftUIColor)
        }
        .padding(.horizontal)
        .padding(.top)
        .background(Token.white.swiftUIColor)
    }
}

// MARK: - Status Option Row for Filter Sheet
struct StockInputOptionRow: View {
    let name: String
    let inputStatusValue: Bool
    
    @Binding var selectedStockInputStatus: Bool?
    
    var isSelected: Bool {
        selectedStockInputStatus == inputStatusValue
    }
    
    func optionIsTapped() {
        if isSelected {
            selectedStockInputStatus = nil
        } else {
            selectedStockInputStatus = inputStatusValue
        }
    }
    
    var body: some View {
        Button {
            optionIsTapped()
        } label: {
            HStack {
                Text(name)
                    .font(.customFont(size: 13, weight: .regular))
                    .foregroundColor(Token.black.swiftUIColor)
                
                Spacer()
                
                Image(uiImage: isSelected ? RiSTOCKIcon.circleFill.image : RiSTOCKIcon.circleEmpty.image)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(isSelected ? .blue : Color(.systemGray3))
            }
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// MARK: - Status Option Row for Filter Sheet
struct StockStatusOptionRow: View {
    let name: String
    let statusStock: StockStatus?

    @Binding var selectedStockStatusSet: Set<StockStatus>

    var isSelected: Bool {
        guard let status = statusStock else { return false }
        return selectedStockStatusSet.contains(status)
    }
    
    func optionIsTapped() {
        guard let status = statusStock else { return }
        
        if isSelected {
            selectedStockStatusSet.remove(status)
        } else {
            selectedStockStatusSet.insert(status)
        }
    }
    
    var body: some View {
        Button {
            optionIsTapped()
        } label: {
            HStack {
                Text(name)
                    .font(.customFont(size: 13, weight: .regular))
                    .foregroundColor(Token.black.swiftUIColor)
                
                Spacer()
                
                Image(uiImage: isSelected ? RiSTOCKIcon.checkActive.image : RiSTOCKIcon.checkInactive.image)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(isSelected ? .blue : Color(.systemGray3))
            }
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// MARK: - Preview
struct SearchAndFilter_PreviewContainer: View {
    @State private var text: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        SearchAndFilter(
            searchText: $text,
            isChecked: .constant(nil),
            selectedStockStatusFilter: .constant([]),
            isSearchFieldFocused: $isFocused
        )
        
        Spacer()
    }
}

#Preview {
    SearchAndFilter_PreviewContainer()
}


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
    
    @FocusState.Binding var isSearchFieldFocused: Bool
    
    // MARK: State Properties
    @State private var isFilterPresented: Bool = false {
        didSet {
            if isFilterPresented {
                isCheckedForFilter = isChecked
            }
        }
    }
    
    @State private var isCheckedForFilter: Bool? = nil
    
    @State private var showTrailingButton = true

    var body: some View {
        HStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Token.gray500.swiftUIColor)
                
                TextField("", text: $searchText)
                    .placeholder(when: searchText.isEmpty) {
                            Text("Search produk..")
                            .font(.system(size: 15))
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
            .background(Token.gray50.swiftUIColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isSearchFieldFocused)
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: showTrailingButton)

            if showTrailingButton {
                if isSearchFieldFocused {
                    Button {
                        cancelSearchIsTapped()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Token.gray500.swiftUIColor)
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    Button {
                        filterButtonIsTapped()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(isChecked == nil ? Token.gray500.swiftUIColor : Token.primary50.swiftUIColor)
                            .frame(width: 40, height: 40)
                            .background(isChecked == nil ? Token.gray50.swiftUIColor: Token.primary500.swiftUIColor)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white)
        .sheet(isPresented: $isFilterPresented) {
            filterSheet()
                .presentationDetents([.fraction(0.4)])
        }
        .onChange(of: isSearchFieldFocused) { _, focused in
            if focused {
                // Step 1: expand immediately
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    showTrailingButton = false
                }
                // Step 2: show Cancel slightly after (staged)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        showTrailingButton = true
                    }
                }
            } else {
                // Reverse sequence
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    showTrailingButton = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
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
        isFilterPresented = false
    }
    
    func filterSheetButtonApplyFilterTapped() {
        isChecked = isCheckedForFilter
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

                Text("Filter Cek Stok")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 20)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text("Status Cek")
                        .font(.system(size: 15, weight: .semibold))
                        .padding(.top, 8)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 0) {
                    
                        StatusOptionRow(
                            name: "Perlu di cek",
                            statusValue: false,
                            selectedStatus: $isCheckedForFilter
                        )
                        
                        StatusOptionRow(
                            name: "Sudah di cek",
                            statusValue: true,
                            selectedStatus: $isCheckedForFilter
                        )
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
                    
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    Button("Hapus") {
                        filterSheetButtonRemoveFilterTapped()
                    }
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 15, weight: .medium))
                    .padding(.vertical, 12)
                    .background(Token.primary50.swiftUIColor)
                    .foregroundColor(Token.primary500.swiftUIColor)
                    .cornerRadius(100)
                    
                    Button("Pakai") {
                        filterSheetButtonApplyFilterTapped()
                    }
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 15, weight: .medium))
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
struct StatusOptionRow: View {
    let name: String
    let statusValue: Bool
    
    @Binding var selectedStatus: Bool?
    
    var isSelected: Bool {
        selectedStatus == statusValue
    }
    
    func optionIsTapped() {
        if isSelected {
            selectedStatus = nil
        } else {
            selectedStatus = statusValue
        }
    }
    
    var body: some View {
        Button {
            optionIsTapped()
        } label: {
            HStack {
                Text(name)
                    .font(.system(size: 13))
                    .foregroundColor(Token.black.swiftUIColor)
                
                Spacer()
                
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
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
            isSearchFieldFocused: $isFocused
        )
        
        Spacer()
    }
}

#Preview {
    SearchAndFilter_PreviewContainer()
}


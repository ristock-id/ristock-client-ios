//
//  SearchAndFilter.swift
//  RiSTOCK-Client
//
//  Created by Rico Tandrio on 14/11/25.
//

import Foundation
import SwiftUI

struct SearchAndFilter: View {
    @Binding var searchText: String
    @Binding var isChecked: Bool?
    
    @FocusState.Binding var isSearchFieldFocused: Bool
    
    @State private var isFilterPresented: Bool = false
    
    var body: some View {
        HStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(uiColor: .systemGray))
                
                TextField("Search produk..", text: $searchText)
                    .disableAutocorrection(true)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color(uiColor: .systemGray6))
            .clipShape(Capsule())
            
            Button {
                isFilterPresented.toggle()
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(Color(uiColor: .systemGray))
                    .padding(10)
                    .background(Color(uiColor: .systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white)
        .sheet(isPresented: $isFilterPresented) {
            filterSheet()
                .presentationDetents([.fraction(0.4)])
        }
    }
    
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
                            statusValue: true,
                            selectedStatus: $isChecked
                        )
                        
                        StatusOptionRow(
                            name: "Sudah di cek",
                            statusValue: false,
                            selectedStatus: $isChecked
                        )
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
                    
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    Button("Hapus") {
                        isChecked = nil
                        isFilterPresented = false
                    }
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 15, weight: .medium))
                    .padding(.vertical, 12)
                    .background(Token.primary50.swiftUIColor)
                    .foregroundColor(Token.primary500.swiftUIColor)
                    .cornerRadius(100)
                    
                    Button("Pakai") {
                        isFilterPresented = false
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

struct StatusOptionRow: View {
    let name: String
    let statusValue: Bool
    
    @Binding var selectedStatus: Bool?
    
    var isSelected: Bool {
        selectedStatus == statusValue
    }
    
    var body: some View {
        Button {
            if isSelected {
                selectedStatus = nil
            } else {
                selectedStatus = statusValue
            }
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


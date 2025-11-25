//
//  ProductRow.swift
//  RiSTOCK-Client
//
//  Created by Akbar Febry on 15/11/25.
//

import SwiftUI
import Lottie

struct ProductRow: View {
    let index: Int
    @Binding var product: ProductSummaryUI1 // TODO: Ini masih pake mock data, harus diganti
    
    // Data Stok
    let stockAmount: Int?
    let minStock: Int // TODO: Dari hasil perhitungan backend
    let stockStatus: String? // Label status
    
    let priority: String // "High" = 🔥
    let onAddTap: () -> Void // Action (+)
    
    // TODO: Logic priority harus disesuaiin lagi
    // Cek prioritas
    private var isHighPriority: Bool {
        return priority.lowercased() == "high"
    }
    
    // Logic warna berdasarkan minStock
    private var statusColor: Color {
        guard let stock = stockAmount else { return .blue }
        
        if stock == 0 {
            return Token.error300.swiftUIColor // Habis
        } else if stock < minStock {
            return Token.warning400.swiftUIColor // Menipis
        } else {
            return Token.success300.swiftUIColor //Aman
        }
    }
    
    // Logic ratio bar berdasarkan minStock
    private var progressRatio: CGFloat {
        guard let stock = stockAmount else { return 0 }
        
        if stock == 0 {
            return 0.15
        }
        
        if stock >= minStock {
            return 1.0
        }
        
        return CGFloat(stock) / CGFloat(minStock)
    }
    
    var body: some View {
        // Logic button or view
        Button(action: onAddTap) {
            cardContent
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Main content layout
    private var cardContent: some View {
        HStack(alignment: .center, spacing: 12) {
            
            // Index & Priority
            HStack(alignment: .center, spacing: 1) {
                Text("\(index)")
                    .font(.customFont(size: 15, weight: .regular))
                    .padding(.leading, 13)
                
                if isHighPriority {
                    LottieView(animation: RiSTOCKAnimation.fire)
                        .playbackMode(.playing(.fromProgress(0, toProgress: 1, loopMode: .loop)))
                        .resizable()
                        .frame(width: 15, height: 20)
                        .offset(y: -3.5)
                }
            }
            .frame(minWidth: 35, alignment: .leading)
            
            // Nama Produk
            Text(product.name)
                .font(.customFont(size: 15, weight: .regular))
                .padding(.horizontal, 13)
            
            Spacer()
            
            // State logic (Button or Bar)
            if let stock = stockAmount {
                stockDisplayView(stock: stock) // Tampilkan bar
            } else {
                addButtonView() // Tampilkan add button
            }
        }
        .padding(.leading, 12)
        .padding(.trailing, 20)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Token.white.swiftUIColor)
                .shadow(color: Token.black.swiftUIColor.opacity(0.2), radius: 2, x: 0, y: 1)
        )
    }
    
    // MARK: - Subviews
    
    // View untuk button (+)
    private func addButtonView() -> some View {
        Image(systemName: "plus")
            .font(.system(size: 15, weight: .bold))
            .foregroundColor(Token.primary600.swiftUIColor)
            .frame(width: 24, height: 24)
            .background(Color(Token.primary50.swiftUIColor))
            .clipShape(Circle())
    }
    
    // view untuk Tampilan Stok & Bar
    private func stockDisplayView(stock: Int) -> some View {
        VStack(alignment: .trailing, spacing: 5) {
            // Angka stok
            Text("\(stock)")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Token.black.swiftUIColor)
            
            // Progress bar
            ZStack(alignment: .leading) {
                // Background (gray)
                Capsule()
                    .fill(Token.gray50.swiftUIColor)
                    .frame(width: 50, height: 10)
                
                // Foreground (dinamis)
                Capsule()
                    .fill(statusColor)
                    .frame(width: 50 * progressRatio, height: 10)
                    .animation(.spring(), value: progressRatio)
            }
            .mask(Capsule())
        }
    }
}

// MARK: - Preview Logic
struct ProductRow_Previews: PreviewProvider {
    
    // Dummy State Wrapper untuk Binding
    struct PreviewWrapper: View {
        // Dummy Data ProductSummaryUI (Sesuaikan dengan struct kamu)
        @State var product1 = ProductSummaryUI1(id: "1", name: "1lusin cetakan kue putu (Input)", stockStatus: "EMPTY")
        @State var product2 = ProductSummaryUI1(id: "2", name: "1lusin cetakan kue putu (Aman)", stockStatus: "SAFE")
        @State var product3 = ProductSummaryUI1(id: "3", name: "1lusin cetakan kue putu (Menipis)", stockStatus: "LOW")
        @State var product4 = ProductSummaryUI1(id: "4", name: "1lusin cetakan kue putu (Habis)", stockStatus: "OUT")
        @State var product5 = ProductSummaryUI1(id: "5", name: "Barang Biasa Low Priority", stockStatus: "SAFE")

        var body: some View {
            ZStack {
                Color.gray.opacity(0.1).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        
                        // Case 1: Input Mode (stockAmount = nil)
                        ProductRow(
                            index: 1,
                            product: $product1,
                            stockAmount: nil,
                            minStock: 50,
                            stockStatus: nil,
                            priority: "High",
                            onAddTap: { print("Add tapped") }
                        )
                        
                        // Case 2: Aman (Green) - Stock 100 (>= Min 50)
                        ProductRow(
                            index: 2,
                            product: $product2,
                            stockAmount: 100,
                            minStock: 50,
                            stockStatus: "AMAN",
                            priority: "High",
                            onAddTap: {}
                        )
                        
                        // Case 3: Menipis (Yellow) - Stock 30 (< Min 50)
                        ProductRow(
                            index: 3,
                            product: $product3,
                            stockAmount: 30,
                            minStock: 70,
                            stockStatus: "MENIPIS",
                            priority: "High",
                            onAddTap: {}
                        )
                        
                        // Case 4: Habis (Red) - Stock 0
                        ProductRow(
                            index: 4,
                            product: $product4,
                            stockAmount: 0,
                            minStock: 50,
                            stockStatus: "HABIS",
                            priority: "High",
                            onAddTap: {}
                        )
                        
                        // Case 5: Low Priority (No Fire)
                        ProductRow(
                            index: 5,
                            product: $product5,
                            stockAmount: 20,
                            minStock: 10,
                            stockStatus: "AMAN",
                            priority: "Low", // Tidak ada api
                            onAddTap: {}
                        )
                    }
                    .padding()
                }
            }
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}

// MARK: - Mock Data Helper (Hanya untuk Preview agar kode di atas jalan)
// Hapus atau sesuaikan ini jika kamu sudah punya struct ProductSummaryUI sendiri
struct ProductSummaryUI1 {
    var id: String
    var name: String
    var stockStatus: String
    // Tambahkan properti lain jika ada
}

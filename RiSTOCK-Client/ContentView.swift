//
//  ContentView.swift
//  RiSTOCK-Client
//
//  Created by Rico Tandrio on 30/10/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("userId") private var userId: String = ""  
    @State private var isPresentingScanner = false

    var body: some View {
        if !userId.isEmpty {
            VStack(spacing: 16) {
                Text("User ID: \(userId)")
                    .font(.title)
                    .padding()
                
                Button("Logout") {
                    userId = ""
                }
                .buttonStyle(.borderedProminent)
            }
        } else {
            VStack(spacing: 20) {
                Button(action: { isPresentingScanner = true }) {
                    Text("Open Barcode Scanner")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 10).stroke())
                }
                .padding(.horizontal)
                .fullScreenCover(isPresented: $isPresentingScanner) {
                    ScannerView { result in
                        DispatchQueue.main.async {
                            isPresentingScanner = false
                            userId = result
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}

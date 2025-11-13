//
//  ContentView.swift
//  RiSTOCK-Client
//
//  Created by Rico Tandrio on 30/10/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("clientId") private var clientId: String = ""
    @State private var isPresentingScanner = false

    var body: some View {
        if !clientId.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                Text("User ID: \(clientId)")
                    .font(.title)
                    .padding()
                
                Button("Logout") {
                    clientId = ""
                }
                .buttonStyle(.borderedProminent)
                
                ProductStockView(viewModel: ProductStockViewModel(deviceId: clientId))
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
                            clientId = result
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

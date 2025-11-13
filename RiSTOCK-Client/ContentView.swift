//
//  ContentView.swift
//  RiSTOCK-Client
//
//  Created by Rico Tandrio on 30/10/25.
//

import SwiftUI

struct ContentView: View {
    // e2eb2658-3a31-4566-b2a9-7b77c1352fc8
    @AppStorage("clientId") private var clientId: String = ""
    @State private var isPresentingScanner = false
    @State private var isPresentingGallery = false
    @State private var selectedImage: UIImage? = nil {
        didSet {
            if let image = selectedImage {
                // Process the selected image to extract barcode
                BarcodeScanner.scanBarcode(from: image) { result in // <-- This function is now defined
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let code):
                            clientId = code // <-- Sets your state variable
                        case .failure(let error):
                            print("Failed to scan barcode from image: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        if !clientId.isEmpty {
//            VStack(alignment: .leading, spacing: 16) {
//                Text("User ID: \(clientId)")
//                    .font(.title)
//                    .padding()
//                
//                Button("Logout") {
//                    clientId = ""
//                }
//                .buttonStyle(.borderedProminent)
//                
                ProductStockView(viewModel: ProductStockViewModel(deviceId: clientId))
//            }
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
                
                Button(action: { isPresentingGallery = true }) {
                    Text("Open Photo Gallery")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.green))
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                .fullScreenCover(isPresented: $isPresentingGallery) {
                    PhotoPicker { image in
                        // The onImagePicked closure handles setting the state
                        self.selectedImage = image
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

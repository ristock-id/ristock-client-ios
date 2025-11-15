//
//  ContentView.swift
//  RiSTOCK-Client
//
//  Created by Rico Tandrio on 30/10/25.
//

import SwiftUI
import UIKit
import AVFoundation
import Photos

struct ContentView: View {

    // e2eb2658-3a31-4566-b2a9-7b77c1352fc8
    @AppStorage("clientId") private var clientId: String = ""
    @State private var isPresentingScanner = false
    @State private var isPresentingGallery = false
    @State private var isProcessingImage = false
    @State private var selectedImage: UIImage? = nil {
        didSet {
            if let image = selectedImage {
                
                isProcessingImage = true
                
                // Process the selected image to extract barcode
                BarcodeScanner.scanBarcode(from: image) { result in
                    DispatchQueue.main.async {
                        isProcessingImage = false
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
    
    // State untuk menangani error modal
    @State private var scannerPermissionError: PermissionError? = nil
    @State private var showConnectionErrorModal = false
    
    var body: some View {
        if !clientId.isEmpty {
            // Placeholder untuk View Produk
            ProductStockView(viewModel: ProductStockViewModel(deviceId: clientId))
        } else {
            VStack(spacing: 20) {
                // Tombol Buka Scanner
                Button(action: {
                    isProcessingImage = false
                    // Reset error state sebelum membuka
                    scannerPermissionError = nil
                    showConnectionErrorModal = false
                    isPresentingScanner = true
                    
                    requestSequentialPermissions()
                }) {
                    Text("Scan QR Code")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 10).stroke())
                }
                .padding(.horizontal)
                .fullScreenCover(isPresented: $isPresentingScanner) {
                    ScannerView(
                        // 1. Hasil Scan (Flow "Koneksi Terputus")
                        didFindCode: { result in
                            DispatchQueue.main.async {
                                isPresentingScanner = false // Tutup scanner
                                
                                // Ganti "NO_INTERNET" dengan kode error-mu
                                if result == "NO_INTERNET" {
                                    showConnectionErrorModal = true
                                } else {
                                    clientId = result
                                }
                            }
                        },
                        // 2. Tombol Galeri (Flow "Izin Galeri")
                        didTapGallery: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isPresentingGallery = true
                            }
                        },
                        // 3. Error Izin
                        permissionError: $scannerPermissionError,
                        isProcessingImage: $isProcessingImage
                    )
                    .edgesIgnoringSafeArea(.all)
                    
                    // Modal untuk Izin Kamera & Galeri
                    .fullScreenCover(item: $scannerPermissionError) { error in
                        
                        let isCameraError = (error == .cameraAccessDenied || error == .noCameraAvailable)
                        let logo = isCameraError ? "cameraAccess" : "galleryAccess"
                        let title = isCameraError ? "Izin Kamera Diperlukan" : "Izin Galeri Diperlukan"
                        let message = isCameraError ? "Izinkan RISTOCK mengakses kamera agar dapat memindai QR Code." : "Izinkan RISTOCK mengakses galeri agar dapat mengunggah gambar."
                        
                        ErrorModal(
                            isPresented: Binding( // Binding manual
                                get: { scannerPermissionError != nil },
                                set: { if !$0 { scannerPermissionError = nil } }
                                                ),
                            errorLogo: logo,
                            errorTitle: title,
                            errorMessage: message,
                            actionButtonTitle: "Pengaturan",
                            cancel: true,
                            action: {
                                // Aksi "Pengaturan"
                                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                                if UIApplication.shared.canOpenURL(settingsUrl) {
                                    UIApplication.shared.open(settingsUrl)
                                }
                                scannerPermissionError = nil
                            }
                        )
                        .presentationBackground(.clear)
                    }
                    // Modal untuk Galeri (sudah benar)
                    .fullScreenCover(isPresented: $isPresentingGallery) {
                        PhotoPicker { image in
                            self.selectedImage = image
                            isPresentingGallery = false
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private func requestSequentialPermissions() {
        // 1. Minta Izin Kamera
        requestCameraPermission { [self] cameraGranted in
        // 2. Setelah selesai, Minta Izin Galeri
        requestGalleryPermission { [self] galleryGranted in
            // 3. Tentukan status error (jika ada)
            if !cameraGranted {
                self.scannerPermissionError = .cameraAccessDenied
                } else if !galleryGranted {
                    self.scannerPermissionError = .galleryAccessDenied
                } else {
                    self.scannerPermissionError = nil
                }
            // 4. Buka Scanner
            self.isPresentingScanner = true
            }
        }
    }
        
    // Cek atau minta izin kamera
    private func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            completion(true) // Sudah diizinkan
        case .notDetermined:
            // Minta izin (pop-up sistem akan muncul)
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied, .restricted:
            completion(false) // Sudah ditolak
        @unknown default:
            completion(false)
        }
    }
        
    // Cek atau minta izin galeri
    private func requestGalleryPermission(completion: @escaping (Bool) -> Void) {
        // Gunakan level .readWrite atau .addOnly sesuai kebutuhan
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            completion(true) // Sudah diizinkan
        case .notDetermined:
            // Minta izin (pop-up sistem akan muncul)
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        case .denied, .restricted:
            completion(false) // Sudah ditolak
        @unknown default:
            completion(false)
        }
    }
}

#Preview {
    ContentView()
}

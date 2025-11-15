//
//  ScannerView.swift
//  RiSTOCK-Client
//
//  Created by Rico Tandrio on 30/10/25.
//

import UIKit
import SwiftUI

struct ScannerView: UIViewControllerRepresentable {
    var didFindCode: (String) -> Void
    var didTapGallery: () -> Void
    
    @Binding var permissionError: PermissionError?
    @Binding var isProcessingImage: Bool

    func makeUIViewController(context: Context) -> ScannerViewController {
        let vc = ScannerViewController()
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        uiViewController.setProcessing(isProcessingImage)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(didFindCode: didFindCode, didTapGallery: didTapGallery, permissionError: $permissionError, isProcessingImage: $isProcessingImage)
    }

    class Coordinator: NSObject, ScannerViewControllerDelegate {
        var didFindCode: (String) -> Void
        var didTapGallery: () -> Void
        @Binding var permissionError: PermissionError?
        @Binding var isProcessingImage: Bool
        
        init(didFindCode: @escaping (String) -> Void, didTapGallery: @escaping () -> Void, permissionError: Binding<PermissionError?>, isProcessingImage: Binding<Bool>) {
            self.didFindCode = didFindCode
            self.didTapGallery = didTapGallery
            self._permissionError = permissionError
            self._isProcessingImage = isProcessingImage
        }
        func scannerViewController(_ controller: ScannerViewController, didFind code: String) {
            didFindCode(code)
        }
        
        func scannerViewControllerDidTapGallery(_ controller: ScannerViewController) {
            didTapGallery()
        }
        
        func scannerViewControllerDidFail(with error: PermissionError) {
            DispatchQueue.main.async {
                self.permissionError = error
            }
        }
        
        func scannerViewControllerDidFixPermission(_ controller: ScannerViewController) {
            DispatchQueue.main.async {
                self.permissionError = nil
            }
        }
    }
}

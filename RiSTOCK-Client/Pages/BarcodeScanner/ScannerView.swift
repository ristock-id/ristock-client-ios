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

    func makeUIViewController(context: Context) -> ScannerViewController {
        let vc = ScannerViewController()
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(didFindCode: didFindCode)
    }

    class Coordinator: NSObject, ScannerViewControllerDelegate {
        var didFindCode: (String) -> Void
        init(didFindCode: @escaping (String) -> Void) {
            self.didFindCode = didFindCode
        }
        func scannerViewController(_ controller: ScannerViewController, didFind code: String) {
            didFindCode(code)
        }
    }
}

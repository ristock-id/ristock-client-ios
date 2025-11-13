//
//  BarcodeScanner.swift
//  RiSTOCK-Client
//
//  Created by Rico Tandrio on 13/11/25.
//

import UIKit
import Vision

// MARK: - Error Handling
enum BarcodeScanError: Error {
    case failedToConvertImage
    case noBarcodeFound
    case unknownError(String)
}

// MARK: - Barcode Scanner Utility
struct BarcodeScanner {

    /// Scans a UIImage for a barcode or QR code and returns the string result.
    static func scanBarcode(from image: UIImage, completion: @escaping (Result<String, BarcodeScanError>) -> Void) {
        
        // Convert UIImage to CGImage
        guard let cgImage = image.cgImage else {
            completion(.failure(.failedToConvertImage))
            return
        }

        // Create a barcode detection request
        let request = VNDetectBarcodesRequest { request, error in
            if let error = error {
                completion(.failure(.unknownError(error.localizedDescription)))
                return
            }
            
            if let results = request.results as? [VNBarcodeObservation],
               let first = results.first,
               let payload = first.payloadStringValue {
                DispatchQueue.main.async {
                    completion(.success(payload))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(.noBarcodeFound))
                }
            }
        }

        // Perform the request
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.unknownError(error.localizedDescription)))
                }
            }
        }
    }
}

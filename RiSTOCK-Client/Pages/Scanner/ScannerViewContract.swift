//
//  ScannerViewContract.swift
//  RiSTOCK-Client
//
//  Created by Rico Tandrio on 30/10/25.
//

import UIKit

enum PermissionError: Identifiable {
    case cameraAccessDenied
    case galleryAccessDenied
    case noCameraAvailable
    
    var id: String {
        switch self {
        case .cameraAccessDenied: return "camera_denied"
        case .galleryAccessDenied: return "gallery_denied"
        case .noCameraAvailable: return "no_camera"
        }
    }
}

protocol ScannerViewControllerDelegate: AnyObject {
    func scannerViewController(_ controller: ScannerViewController, didFind code: String)
    func scannerViewControllerDidTapGallery(_ controller: ScannerViewController)
    func scannerViewControllerDidFail(with error: PermissionError)
    func scannerViewControllerDidFixPermission(_ controller: ScannerViewController)
}

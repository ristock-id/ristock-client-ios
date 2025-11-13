//
//  ScannerViewContract.swift
//  RiSTOCK-Client
//
//  Created by Rico Tandrio on 30/10/25.
//

import UIKit

protocol ScannerViewControllerDelegate: AnyObject {
    func scannerViewController(_ controller: ScannerViewController, didFind code: String)
}

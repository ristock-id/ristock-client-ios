//
//  AnimatedScannerView.swift
//  RiSTOCK-Client
//
//  Created by Andrea Octaviani on 15/11/25.
//

import UIKit
import SwiftUI

class AnimatedScannerView: UIView {
    
    private let scanAreaHeight: CGFloat = 290
    private let scannerLineWidth: CGFloat = 290
    private let scannerLineHeight: CGFloat = 5
    
    private let trailingRectWidth: CGFloat = 290
    private let trailingRectHeight: CGFloat = 275
    private let trailingRectCornerRadius: CGFloat = 12
    private let trailingRectOpacity: CGFloat = 0.5
    
    private let animationDuration: Double = 1.2
    private let scannerColor = UIColor(named: "accent-500") ?? .green
    
    // Group yang bergerak (sesuai ZStack di SwiftUI)
    private let contentGroup = UIView()
    
    // Subview dari contentGroup
    private let scannerLine = UIView()
    private let trailingRect = UIView()
    
    // Gradient
    private let upwardTrailGradient = CAGradientLayer()   // [Transparan, Solid]
    private let downwardTrailGradient = CAGradientLayer() // [Solid, Transparan]
    
    // State Animasi
    private var isMovingDown = true
    private var topY: CGFloat = 0
    private var bottomY: CGFloat = 0
    
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    
    private func setup() {
        // Definisikan warna gradien
        let transparentColor = scannerColor.withAlphaComponent(0).cgColor
        let opaqueColor = scannerColor.withAlphaComponent(trailingRectOpacity).cgColor
        
        // GRADIENT UNTUK TRAIL DI BAWAH (Bergerak ke Atas)
        // [Transparan -> Solid]
        upwardTrailGradient.colors = [transparentColor, opaqueColor]
        upwardTrailGradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        upwardTrailGradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        // GRADIENT UNTUK TRAIL DI ATAS (Bergerak ke Bawah)
        // [Solid -> Transparan]
        downwardTrailGradient.colors = [opaqueColor, transparentColor]
        downwardTrailGradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        downwardTrailGradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        // Konfigurasi Views
        scannerLine.backgroundColor = scannerColor
        scannerLine.layer.cornerRadius = scannerLineHeight / 2
        
        trailingRect.layer.cornerRadius = trailingRectCornerRadius
        trailingRect.clipsToBounds = true
        
        // Hierarchy (Sesuai ZStack)
        contentGroup.addSubview(trailingRect)
        contentGroup.addSubview(scannerLine)
        addSubview(contentGroup)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Tentukan batas atas dan bawah dari area pemindaian
        topY = bounds.midY - (scanAreaHeight / 2)
        bottomY = bounds.midY + (scanAreaHeight / 2)
        
        // Atur ukuran 'contentGroup' untuk menampung line dan trail
        let groupWidth = scannerLineWidth
        let groupHeight = trailingRectHeight + scannerLineHeight
        
        // Atur layout internal contentGroup ke posisi awal (Bergerak ke Bawah)
        setupViewsForDirection(isMovingDown: true)
        
        contentGroup.frame = CGRect(
            x: bounds.midX - (groupWidth / 2),
            y: topY - trailingRectHeight, // Posisi awal Y
            width: groupWidth,
            height: groupHeight
        )
        
        // Atur ukuran frame untuk gradient layers
        let trailFrame = CGRect(x: 0, y: 0, width: trailingRectWidth, height: trailingRectHeight)
        upwardTrailGradient.frame = trailFrame
        downwardTrailGradient.frame = trailFrame
    }
    
    private func setupViewsForDirection(isMovingDown: Bool) {
        trailingRect.layer.sublayers?.removeAll()
        
        let trailX = (contentGroup.bounds.width - trailingRectWidth) / 2
        
        if isMovingDown {
            // TRAIL DI ATAS (Bergerak ke Bawah)
            // 1. Posisikan Trail di atas
            trailingRect.frame = CGRect(x: trailX, y: 0, width: trailingRectWidth, height: trailingRectHeight)
            // 2. Posisikan Line di bawah trail
            scannerLine.frame = CGRect(x: 0, y: trailingRectHeight, width: scannerLineWidth, height: scannerLineHeight)
            // 3. Terapkan gradien [Solid -> Transparan]
            trailingRect.layer.addSublayer(upwardTrailGradient)
            
        } else {
            // TRAIL DI BAWAH (Bergerak ke Atas)
            // 1. Posisikan Line di atas
            scannerLine.frame = CGRect(x: 0, y: 0, width: scannerLineWidth, height: scannerLineHeight)
            // 2. Posisikan Trail di bawah line
            trailingRect.frame = CGRect(x: trailX, y: scannerLineHeight, width: trailingRectWidth, height: trailingRectHeight)
            // 3. Terapkan gradien [Transparan -> Solid]
            trailingRect.layer.addSublayer(downwardTrailGradient)
        }
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            animate()
        }
    }
    
    private func animate() {
        
        // TOP → BOTTOM
        isMovingDown = true
        setupViewsForDirection(isMovingDown: true)
        
        // Posisikan group agar line ada di 'topY'
        self.contentGroup.frame.origin.y = topY - trailingRectHeight
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveLinear]) {
            // Animasikan group agar line ada di 'bottomY - scannerLineHeight'
            self.contentGroup.frame.origin.y = self.bottomY - self.trailingRectHeight - self.scannerLineHeight
            
        } completion: { _ in
            guard self.window != nil else { return }
            
            // BOTTOM → TOP
            self.isMovingDown = false
            self.setupViewsForDirection(isMovingDown: false)
            
            // Posisikan group agar line ada di 'bottomY - scannerLineHeight'
            self.contentGroup.frame.origin.y = self.bottomY - self.scannerLineHeight
            
            UIView.animate(withDuration: self.animationDuration, delay: 0, options: [.curveLinear]) {
                // Animasikan group agar line ada di 'topY'
                self.contentGroup.frame.origin.y = self.topY
                
            } completion: { _ in
                guard self.window != nil else { return }
                self.animate() // Ulangi loop
            }
        }
    }
}

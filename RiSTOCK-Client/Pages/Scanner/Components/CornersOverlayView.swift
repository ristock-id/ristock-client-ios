//
//  CornersOverlayView.swift
//  RiSTOCK-Client
//
//  Created by Andrea Octaviani on 15/11/25.
//

import UIKit

// MARK: - Perbaikan CornersOverlayView
class CornersOverlayView: UIView {
    
    private let color: UIColor
    private let length: CGFloat
    private let radius: CGFloat
    private let lineWidth: CGFloat
    
    // Layer untuk 4 sudut
    private let topLeftLayer = CAShapeLayer()
    private let topRightLayer = CAShapeLayer()
    private let bottomLeftLayer = CAShapeLayer()
    private let bottomRightLayer = CAShapeLayer()

    init(color: UIColor, length: CGFloat, radius: CGFloat, lineWidth: CGFloat) {
        self.color = color
        self.length = length
        self.radius = radius
        self.lineWidth = lineWidth
        super.init(frame: .zero)
        self.backgroundColor = .clear
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayers() {
        // 1. Buat 1 path 'L' (Top-Left)
        let cornerPath = UIBezierPath()
        cornerPath.move(to: CGPoint(x: 0, y: length))
        cornerPath.addLine(to: CGPoint(x: 0, y: radius))
        cornerPath.addArc(withCenter: CGPoint(x: radius, y: radius),
                    radius: radius,
                    startAngle: .pi, endAngle: .pi * 1.5, clockwise: true)
        cornerPath.addLine(to: CGPoint(x: length, y: 0))
        
        // 2. Konfigurasi umum untuk semua layer
        let layers = [topLeftLayer, topRightLayer, bottomLeftLayer, bottomRightLayer]
        for layer in layers {
            layer.path = cornerPath.cgPath
            layer.strokeColor = color.cgColor
            layer.lineWidth = lineWidth
            layer.fillColor = UIColor.clear.cgColor
            layer.lineCap = .round
            layer.lineJoin = .round
            layer.backgroundColor = UIColor.clear.cgColor
            self.layer.addSublayer(layer)
        }
    }
    
    // 3. Posisikan dan rotasikan layer saat layout berubah
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = bounds.width
        let height = bounds.height
        
        // Top-Left (Jangkar di 0,0. Posisi di 0,0. Rotasi 0)
        topLeftLayer.frame = bounds
        topLeftLayer.anchorPoint = .zero
        topLeftLayer.position = .zero
        topLeftLayer.transform = CATransform3DIdentity

        // Top-Right (Jangkar di 0,0. Posisi di width,0. Rotasi 90)
        topRightLayer.frame = bounds
        topRightLayer.anchorPoint = .zero
        topRightLayer.position = CGPoint(x: width, y: 0)
        topRightLayer.transform = CATransform3DMakeRotation(.pi / 2, 0, 0, 1)
        
        // Bottom-Left (Jangkar di 0,0. Posisi di 0,height. Rotasi -90)
        bottomLeftLayer.frame = bounds
        bottomLeftLayer.anchorPoint = .zero
        bottomLeftLayer.position = CGPoint(x: 0, y: height)
        bottomLeftLayer.transform = CATransform3DMakeRotation(-.pi / 2, 0, 0, 1)
        
        // Bottom-Right (Jangkar di 0,0. Posisi di width,height. Rotasi 180)
        bottomRightLayer.frame = bounds
        bottomRightLayer.anchorPoint = .zero
        bottomRightLayer.position = CGPoint(x: width, y: height)
        bottomRightLayer.transform = CATransform3DMakeRotation(.pi, 0, 0, 1)
    }
}

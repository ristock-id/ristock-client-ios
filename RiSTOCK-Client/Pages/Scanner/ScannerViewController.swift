//
//  ScannerViewController.swift
//  RiSTOCK-Client
//
//  Created by Rico Tandrio on 30/10/25.
//

import AVFoundation
import UIKit

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: ScannerViewControllerDelegate?

    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        #if targetEnvironment(simulator)
        let label = UILabel()
        label.text = "Camera not available in Simulator"
        label.textColor = .white
        label.textAlignment = .center
        label.frame = view.bounds
        view.addSubview(label)
        return
        #endif

        setupCaptureSession()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    private func setupCaptureSession() {
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {
            showError("No camera available")
            return
        }

        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            showError("Can't access camera")
            return
        }

        if session.canAddInput(videoInput) { session.addInput(videoInput) }

        let metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [
                .ean8, .ean13, .upce, .code39, .code39Mod43,
                .code93, .code128, .qr, .pdf417, .aztec
            ]
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
        if let layer = previewLayer {
            view.layer.addSublayer(layer)
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }

        setupUIOverlay()
    }

    private func setupUIOverlay() {
        // Close button
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        closeButton.layer.cornerRadius = 8
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 80),
            closeButton.heightAnchor.constraint(equalToConstant: 36)
        ])

        // Dim overlay with cutout
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)

        let scanSize: CGFloat = 250
        let scanRect = CGRect(
            x: (view.frame.width - scanSize) / 2,
            y: (view.frame.height - scanSize) / 2.5,
            width: scanSize,
            height: scanSize
        )

        let path = UIBezierPath(rect: view.bounds)
        let squarePath = UIBezierPath(roundedRect: scanRect, cornerRadius: 12)
        path.append(squarePath)
        path.usesEvenOddFillRule = true

        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        overlayView.layer.mask = maskLayer

        let border = CAShapeLayer()
        border.path = squarePath.cgPath
        border.strokeColor = UIColor.white.cgColor
        border.lineWidth = 2
        border.fillColor = UIColor.clear.cgColor
        overlayView.layer.addSublayer(border)

        view.addSubview(overlayView)
        view.bringSubviewToFront(closeButton)
    }

    @objc private func closeTapped() {
        session.stopRunning()
        dismiss(animated: true)
    }

    private func showError(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Scanner Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.dismiss(animated: true)
            })
            self.present(alert, animated: true)
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let metadata = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadata.stringValue else { return }

        session.stopRunning()
        delegate?.scannerViewController(self, didFind: stringValue)
        dismiss(animated: true)
    }

    deinit {
        if session.isRunning { session.stopRunning() }
    }
}

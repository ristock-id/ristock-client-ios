//
//  ScannerViewController.swift
//  RiSTOCK-Client
//
//  Created by Rico Tandrio on 30/10/25.
//

import AVFoundation
import UIKit
import PhotosUI

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: ScannerViewControllerDelegate?

    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private let animatedScanner = AnimatedScannerView()
    private let galleryButton = UIButton(type: .system)
    private let processingSpinner = UIActivityIndicatorView(style: .large)
    
    private let mainFrameSize: CGFloat = 300
    private let cornerLength: CGFloat = 54
    private let cornerRadius: CGFloat = 14
    private let cornerLineWidth: CGFloat = 5
    private lazy var qrBorderColor = UIColor(named: "primary-700") ?? .blue
    
    private lazy var scanRect: CGRect = {
        return CGRect(
            x: (view.bounds.width - mainFrameSize) / 2,
            y: (view.bounds.height - mainFrameSize) / 2.5,
            width: mainFrameSize,
            height: mainFrameSize
        )
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(appWillEnterForeground),
                                             name: UIApplication.willEnterForegroundNotification,
                                             object: nil)

        #if targetEnvironment(simulator)
        let label = UILabel()
        label.text = "Camera not available in Simulator"
        label.textColor = .white
        label.textAlignment = .center
        label.frame = view.bounds
        view.addSubview(label)
        setupUIOverlay() // Tampilkan UI di simulator
        return
        #endif
        
        // Tampilkan UI statis (dim, tombol, sudut)
        setupUIOverlay()
        
        // Cek izin & mulai kamera
        checkCameraPermission()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    

    @objc private func appWillEnterForeground() {
        if view.window != nil {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            if status == .authorized {
                // Delegate menutup pop-up
                delegate?.scannerViewControllerDidFixPermission(self)
                
                // Izin baru saja diberikan, tampilkan garis
                self.animatedScanner.isHidden = false
                
                // Restart sesi (viewWillAppear juga akan menangani ini)
                if !session.isRunning {
                    viewWillAppear(true)
                }
            }
        }
    }
    
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            setupCaptureSession()
            self.animatedScanner.isHidden = false // Tampilkan garis
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.setupCaptureSession()
                        self?.animatedScanner.isHidden = false // Tampilkan garis
                    } else {
                        // Ditolak, panggil delegate (garis tetap tersembunyi)
                        self?.delegate?.scannerViewControllerDidFail(with: .cameraAccessDenied)
                    }
                }
            }
            
        case .denied, .restricted:
            // Ditolak, panggil delegate (garis tetap tersembunyi)
            delegate?.scannerViewControllerDidFail(with: .cameraAccessDenied)
            
        @unknown default:
            delegate?.scannerViewControllerDidFail(with: .noCameraAvailable)
        }
    }

    private func setupCaptureSession() {
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {
            delegate?.scannerViewControllerDidFail(with: .noCameraAvailable)
            return
        }

        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            delegate?.scannerViewControllerDidFail(with: .cameraAccessDenied)
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
            view.layer.insertSublayer(layer, at: 0)
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }

    private func setupUIOverlay() {
        let scanRect = CGRect(
            x: (view.bounds.width - mainFrameSize) / 2,
            y: (view.bounds.height - mainFrameSize) / 2.5,
            width: mainFrameSize,
            height: mainFrameSize
        )
        
        // Dim overlay with cutout
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let path = UIBezierPath(rect: view.bounds)
        let squarePath = UIBezierPath(roundedRect: scanRect, cornerRadius: cornerRadius)
        path.append(squarePath)
        path.usesEvenOddFillRule = true
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        overlayView.layer.mask = maskLayer
        
        view.addSubview(overlayView)
        
        // Close button (Style disesuaikan dgn screenshot)
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        closeButton.tintColor = .primary700 // Diubah
        closeButton.backgroundColor = .white // Diubah
        closeButton.layer.cornerRadius = 22
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        
        // Gallery button (Style disesuaikan dgn screenshot)
        galleryButton.setTitle("Upload dari galeri", for: .normal)
        galleryButton.setImage(UIImage(systemName: "photo.fill"), for: .normal)
        galleryButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        galleryButton.tintColor = .primary700 // Diubah
        galleryButton.setTitleColor(.primary700, for: .normal) // Diubah
        galleryButton.backgroundColor = .white
        galleryButton.layer.cornerRadius = 24
        galleryButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        galleryButton.translatesAutoresizingMaskIntoConstraints = false
        galleryButton.addTarget(self, action: #selector(didTapGallery), for: .touchUpInside)
        view.addSubview(galleryButton)
        
        // Corners overlay
        let cornersView = CornersOverlayView(
            color: qrBorderColor,
            length: cornerLength,
            radius: cornerRadius,
            lineWidth: cornerLineWidth
        )
        cornersView.frame = scanRect
        view.addSubview(cornersView)
        
        // Animated scanner line
        animatedScanner.frame = scanRect
        animatedScanner.clipsToBounds = true
        animatedScanner.isHidden = true
        view.addSubview(animatedScanner)
        
        // Loading
        processingSpinner.color = .white
        processingSpinner.center = CGPoint(x: scanRect.midX, y: scanRect.midY)
        processingSpinner.hidesWhenStopped = true
        view.addSubview(processingSpinner)
        
        // Constraints
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            
            galleryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            galleryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            galleryButton.widthAnchor.constraint(equalToConstant: 300), // Diubah ke 220
            galleryButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        view.bringSubviewToFront(cornersView)
    }

    @objc private func closeTapped() {
        session.stopRunning()
        dismiss(animated: true)
    }
    
    @objc private func didTapGallery() {
        session.stopRunning()
        
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            delegate?.scannerViewControllerDidTapGallery(self)
        
        case .denied, .restricted:
            delegate?.scannerViewControllerDidFail(with: .galleryAccessDenied)
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self?.delegate?.scannerViewControllerDidTapGallery(self!)
                    } else {
                        // Ditolak, tampilkan modal
                        self?.delegate?.scannerViewControllerDidFail(with: .galleryAccessDenied)
                    }
                }
            }
        @unknown default:
            fatalError("Status photo library not handled")
        }
    }
    
    public func setProcessing(_ isProcessing: Bool) {
        DispatchQueue.main.async {[weak self] in
            guard let self = self else { return }
            
            if isProcessing {
                self.processingSpinner.startAnimating()
                self.animatedScanner.isHidden = true
                self.galleryButton.isEnabled = false
                self.galleryButton.alpha = 0.5
            } else {
                self.processingSpinner.stopAnimating()
                self.galleryButton.isEnabled = true
                self.galleryButton.alpha = 1
                
                let status = AVCaptureDevice.authorizationStatus(for: .video)
                self.animatedScanner.isHidden = (status != .authorized)
            }
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let metadata = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadata.stringValue else { return }
        
        print("✅ Hasil Scan QR: \(stringValue)")

        session.stopRunning()
        delegate?.scannerViewController(self, didFind: stringValue)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        if session.isRunning { session.stopRunning() }
    }
}

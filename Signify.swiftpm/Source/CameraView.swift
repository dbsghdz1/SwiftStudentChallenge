//
//  CameraView.swift
//  Signify
//
//  Created by 김윤홍 on 1/26/25.
//

import SwiftUI
import AVFoundation
import Vision

// MARK: - SwiftUI Camera View
struct CameraView: View {
    @StateObject private var cameraViewModel = CameraViewModel()
    
    var body: some View {
        ZStack {
            CameraPreviewView(session: cameraViewModel.session)
                .edgesIgnoringSafeArea(.all)
            
            // Detection Overlay
            GeometryReader { geometry in
                ForEach(cameraViewModel.detectionResults, id: \.self) { result in
                    DetectionOverlayView(result: result, screenSize: geometry.size)
                }
            }
        }
        .onAppear {
            cameraViewModel.startSession()
        }
        .onDisappear {
            cameraViewModel.stopSession()
        }
    }
}

// MARK: - Camera Preview View
struct CameraPreviewView: UIViewControllerRepresentable {
    let session: AVCaptureSession
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = CameraPreviewViewController(session: session)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

// MARK: - Camera Preview UIViewController
class CameraPreviewViewController: UIViewController {
    private let session: AVCaptureSession
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    init(session: AVCaptureSession) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
    }
}

// MARK: - Detection Overlay View
struct DetectionOverlayView: View {
    let result: DetectionResult
    let screenSize: CGSize
    
    var body: some View {
        let frame = CGRect(x: result.boundingBox.minX * screenSize.width,
                           y: (1 - result.boundingBox.maxY) * screenSize.height,
                           width: result.boundingBox.width * screenSize.width,
                           height: result.boundingBox.height * screenSize.height)
        
        return RoundedRectangle(cornerRadius: 10)
            .stroke(Color.yellow, lineWidth: 2)
            .frame(width: frame.width, height: frame.height)
            .position(x: frame.midX, y: frame.midY)
            .overlay(
                VStack {
                    Text(result.identifier)
                        .font(.headline)
                        .foregroundColor(.black)
                    Text(String(format: "Confidence: %.2f", result.confidence))
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
                .padding(5)
                .background(Color.white.opacity(0.7))
                .cornerRadius(5),
                alignment: .top
            )
    }
}

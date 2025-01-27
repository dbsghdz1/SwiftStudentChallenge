//
//  CameraViewModel.swift
//  Signify
//
//  Created by 김윤홍 on 1/27/25.
//
import SwiftUI
import AVFoundation
import Vision

class CameraViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let visionRequestQueue = DispatchQueue(label: "com.Signify.SwiftStudentChallenge")
    private var visionRequests = [VNRequest]()
    
    let session = AVCaptureSession()
    @Published var detectionResults: [DetectionResult] = []
    
    @MainActor
    override init() {
        super.init()
        setupCamera()
        setupVision()
    }
    
    private func setupCamera() {
        session.beginConfiguration()
        session.sessionPreset = .vga640x480
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let deviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(deviceInput) else {
            print("Unable to access camera")
            return
        }
        
        session.addInput(deviceInput)
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: visionRequestQueue)
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
        
        session.commitConfiguration()
    }
//    @MainActor
//    private func setupVision() {
//        guard let modelURL = Bundle.main.url(forResource: "Resource/MyHandPoseClassifier", withExtension: "mlmodelc"),
//              let model = try? VNCoreMLModel(for: MLModel(contentsOf: modelURL)) else {
//            print("Failed to load CoreML model")
//            return
//        }
//        
//        let request = VNCoreMLRequest(model: model) { [weak self] request, _ in
//            guard let self = self else { return }
//            self.handleVisionResults(request.results)
//        }
//        self.visionRequests = [request]
//    }
//    
    @MainActor
    private func setupVision() {
        // Step 1: Try to locate the model file in the bundle
        guard let modelURL = Bundle.main.url(forResource: "MyHandPoseClassifier", withExtension: "mlmodelc") else {
            print("Error: Could not find 'MyHandPoseClassifier.mlmodelc' in the bundle.")
            return
        }
        
        // Step 2: Attempt to load the CoreML model
        do {
            let mlModel = try MLModel(contentsOf: modelURL)
            let model = try VNCoreMLModel(for: mlModel)
            
            // Step 3: Create a Vision request with the loaded model
            let request = VNCoreMLRequest(model: model) { [weak self] request, _ in
                guard let self = self else { return }
                self.handleVisionResults(request.results)
            }
            self.visionRequests = [request]
            print("Vision model successfully loaded and request created.")
            
        } catch {
            print("Error: Failed to load CoreML model or create Vision request. \(error)")
            return
        }
    }
    
    @MainActor
    private func handleVisionResults(_ results: [Any]?) {
        guard let results = results as? [VNRecognizedObjectObservation], !results.isEmpty else {
            DispatchQueue.main.async { [weak self] in
                self?.detectionResults = []
            }
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.detectionResults = results.map {
                DetectionResult(identifier: $0.labels.first?.identifier ?? "Unknown",
                                confidence: $0.labels.first?.confidence ?? 0,
                                boundingBox: $0.boundingBox)
            }
        }
    }
    func startSession() {
        if !session.isRunning {
            session.startRunning()
        }
    }
    
    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? requestHandler.perform(visionRequests)
    }
}


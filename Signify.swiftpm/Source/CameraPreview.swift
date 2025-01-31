//
//  Untitled.swift
//  Signify
//
//  Created by 김윤홍 on 1/29/25.
//

import Foundation
import AVFoundation
import SwiftUI
import Vision

struct CameraPreviewView: UIViewRepresentable {
    
    private var captureSession = AVCaptureSession()
    private let requests = [VNRequest]()
    private let queue = DispatchQueue(label: "VideoDataOutput",
                                      qos: .userInitiated,
                                      attributes: [],
                                      autoreleaseFrequency: .workItem)
    
    func makeUIView(context: Context) -> UIView {
        let view = PreviewView()
        view.backgroundColor = .black
        if let previewLayer = view.previewLayer {
            previewLayer.session = captureSession
            previewLayer.videoGravity = .resizeAspectFill
//            previewLayer.connection?.videoRotationAngle = 90.0
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // do nothing
    }
    
    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)

            var isAuthorized = status == .authorized
            
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            print(status.rawValue.description)
            return isAuthorized
        }
    }
    
    func setCamera() async {
        guard await isAuthorized else { return }
        
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                  for: .video,
                                                  position: .front)
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        
        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
            captureSession.canAddInput(videoDeviceInput)
            else { return }
        captureSession.addInput(videoDeviceInput)
        
        let output = AVCaptureVideoDataOutput()
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
            output.alwaysDiscardsLateVideoFrames = true
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
//            output.setSampleBufferDelegate(self, queue: queue)
        } else {
            captureSession.commitConfiguration()
            return
        }
        
        captureSession.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation
        
        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = .down
        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        return exifOrientation
    }

}

fileprivate class PreviewView:UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer? {
        return layer as? AVCaptureVideoPreviewLayer
    }
}

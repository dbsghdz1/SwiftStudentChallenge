//
//  CameraManager.swift
//  Signify
//
//  Created by 김윤홍 on 1/31/25.
//

import AVFoundation

class CameraManager {
    
    private var permissionGranted = false
    private let captureSession = AVCaptureSession()
    
    init() {
        checkPermission()
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                permissionGranted = true
                
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { [weak self] result in
                    guard let self else { return }
                    self.permissionGranted = result
                }
                
            default:
                permissionGranted = false
        }
    }
    
    func setupCaptureSession() {
        let videoOutput = AVCaptureVideoDataOutput()
        
        guard permissionGranted else { return }
        
        guard let videoDevice = AVCaptureDevice.default(.builtInDualWideCamera,
                                                        for: .video,
                                                        position: .front) else { return }
        
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        guard captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        captureSession.addOutput(videoOutput)
        videoOutput.connection(with: .video)?.videoOrientation = .landscapeLeft
    }
}

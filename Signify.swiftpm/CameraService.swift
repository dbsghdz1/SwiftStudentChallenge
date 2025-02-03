//
//  CameraService.swift
//  Signify
//
//  Created by 김윤홍 on 2/3/25.
//

import AVFoundation

@MainActor
class CameraService {
    
    let preview = CameraPreview()
    private let captureSession = AVCaptureSession()
    
    func checkPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        var isAuthorized = status == .authorized
        
        if status == .notDetermined {
            isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
        }
        
        return isAuthorized
    }
    
    func setCamera() async {
        guard await checkPermission() else { return }
        
        preview.videoPreviewLayer.session = captureSession
        
        guard
            let videoDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front
        ) else { return }
        
        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
            captureSession.canAddInput(videoDeviceInput)
        else { return }
        
        captureSession.addInput(videoDeviceInput)
        
        let photoOutput = AVCapturePhotoOutput()
        guard
            captureSession.canAddOutput(photoOutput) else { return }
        
        captureSession.addOutput(photoOutput)
        captureSession.startRunning()
    }
}

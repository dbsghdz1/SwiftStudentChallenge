//
//  CameraService.swift
//  Signify
//
//  Created by 김윤홍 on 2/3/25.
//

import AVFoundation
import Vision
import CoreML

//@MainActor
final class CameraService: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @MainActor
    let preview = CameraPreview()
    private let captureSession = AVCaptureSession()
    
    private let mlModel: MyHandPoseClassifier? = {
        do {
            return try MyHandPoseClassifier()
        } catch {
            return nil
        }
    }()
    
    private lazy var handPoseRequest: VNDetectHumanHandPoseRequest = {
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 1
        return request
    }()
    
    @MainActor
    func checkPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        var isAuthorized = status == .authorized
        
        if status == .notDetermined {
            isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
        }
        
        return isAuthorized
    }
    
    @MainActor
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
        
        let videoOutput = AVCaptureVideoDataOutput()
        guard
            captureSession.canAddOutput(videoOutput) else { return }
        
        captureSession.addOutput(videoOutput)
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.startRunning()
    }
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) async {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do {
            try handler.perform([handPoseRequest])
            
            if let observation = handPoseRequest.results?.first {
                let handPoints = try observation.recognizedPoints(.all)
                
                if let inputArray = processHandPoints(handPoints) {
                   runCoreMLModel(inputArray)
                }
            }
        } catch {
            print("🚨 Core ML 분석 중 오류 발생: \(error)")
        }
    }
    
    func processHandPoints(_ handPoints: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]) -> MLMultiArray? {
        
        let joints: [VNHumanHandPoseObservation.JointName] = [
            .wrist, .thumbTip, .thumbIP, .thumbMP, .thumbCMC,
            .indexTip, .indexDIP, .indexPIP, .indexMCP,
            .middleTip, .middleDIP, .middlePIP, .middleMCP,
            .ringTip, .ringDIP, .ringPIP, .ringMCP,
            .littleTip, .littleDIP, .littlePIP, .littleMCP
        ]
        
        do {
            let multiArray = try MLMultiArray(shape: [1, 3, 21], dataType: .float32)
            
            for (index, joint) in joints.enumerated() {
                if let point = handPoints[joint] {
                    let x = Float(point.location.x)
                    let y = Float(point.location.y)
                    let confidence = Float(point.confidence)
                    
                    multiArray[[0, 0, index] as [NSNumber]] = NSNumber(value: x)
                    multiArray[[0, 1, index] as [NSNumber]] = NSNumber(value: y)
                    multiArray[[0, 2, index] as [NSNumber]] = NSNumber(value: confidence)
                }
            }
            return multiArray
        } catch {
            print(error)
        }
        return nil
    }
    
    func runCoreMLModel(_ input: MLMultiArray) {
        guard let model = mlModel else {
            print("🚨 CoreML 모델이 로드되지 않았습니다.")
            return
        }
        
        do {
            let inputFeatureProvider = try MyHandPoseClassifierInput(poses: input)
            let predicition = try model.prediction(input: inputFeatureProvider)
            print(predicition.label)
        } catch {
            print(error)
        }
    }
}

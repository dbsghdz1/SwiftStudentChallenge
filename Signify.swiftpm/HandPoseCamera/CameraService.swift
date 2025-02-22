//
//  CameraService.swift
//  Signify
//
//  Created by 김윤홍 on 2/3/25.
//

@preconcurrency import AVFoundation
import Vision
import CoreML
import UIKit

@available(iOS 17.0, *)
@Observable
final class CameraService: NSObject,
                           AVCaptureVideoDataOutputSampleBufferDelegate,
                           ObservableObject,
                           Sendable {
    
    @MainActor
    var alphabet: String = ""
    @MainActor
    let preview = CameraPreview()
    let captureSession = AVCaptureSession()
    
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
        
        guard let videoDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front
        ) else { return }
        
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(videoDeviceInput) {
                captureSession.addInput(videoDeviceInput)
            }
            
            // 🎯 프레임 속도 설정: 30fps
            try videoDevice.lockForConfiguration()
            videoDevice.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 30)
            videoDevice.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: 30)
            videoDevice.unlockForConfiguration()
            
        } catch {
            print("🚨 카메라 설정 오류: \(error)")
            return
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        guard captureSession.canAddOutput(videoOutput) else { return }
        
        captureSession.addOutput(videoOutput)
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        if let connection = preview.videoPreviewLayer.connection {
            connection.videoOrientation = .landscapeRight
        }
        
        captureSession.startRunning()
    }
    
    internal func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    )  {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let handPoseRequest =  VNDetectHumanHandPoseRequest()
        handPoseRequest.maximumHandCount = 1
        handPoseRequest.revision = VNDetectHumanHandPoseRequestRevision1
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        
        do {
            try handler.perform([handPoseRequest])
            
            if let observation = handPoseRequest.results?.first {
                let handPoints = try observation.recognizedPoints(.all)
                
                if let inputArray = processHandPoints(handPoints) {
                    Task {
                        await MainActor.run {
                            print("")
                        }
                    }
                    runCoreMLModel(inputArray)
                }
            }
        } catch {
            print("🚨 Core ML 분석 중 오류 발생: \(error)")
        }
    }
    
    func processHandPoints(_ handPoints: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]) -> MLMultiArray? {
        let joints: [VNHumanHandPoseObservation.JointName] = [
            .wrist, .thumbCMC, .thumbMP, .thumbIP, .thumbTip,
            .indexMCP, .indexPIP, .indexDIP, .indexTip,
            .middleMCP, .middlePIP, .middleDIP, .middleTip,
            .ringMCP, .ringPIP, .ringDIP, .ringTip,
            .littleMCP, .littlePIP, .littleDIP, .littleTip
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
            print("🚨 MLMultiArray 생성 오류: \(error)")
        }
        return nil
    }
    func runCoreMLModel(_ input: MLMultiArray) {
//        do {
//            let config = MLModelConfiguration()
//            let model = try HandPoseClassifier(configuration: config)
//        }
        
        do {
            let config = MLModelConfiguration()
            let model = try HandPoseClassifier(configuration: config)
            let inputFeatureProvider = HandPoseClassifierInput(poses: input)
            let handPosePrediction = try model.prediction(poses: input)
            let confidence = handPosePrediction.labelProbabilities[handPosePrediction.label]!
            let prediction = try model.prediction(input: inputFeatureProvider)
            let predictedLabel = String(prediction.label)
            
            Task {
                await MainActor.run {
                    if confidence > 0.9 {
//                        print("정확도: \(confidence) : 예측:\(predictedLabel)")
                        self.alphabet = predictedLabel
                    } else {
                        print(predictedLabel)
                    }
                }
            }
        } catch {
            print(error)
        }
    }
}

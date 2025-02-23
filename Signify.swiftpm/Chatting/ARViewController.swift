//
//  ARViewController.swift
//  Signify
//
//  Created by 김윤홍 on 2/22/25.
//

import Foundation
import ARKit

class ARViewController: UIViewController, @preconcurrency ARSessionDelegate {
    
    var arView: ARSCNView!
    var labelText: String = "" {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.secondLabel.text = self.labelText
                print(self.labelText)
            }
            
        }
    }
    
    private var label: UILabel = UILabel()
    private var secondLabel = UILabel()
    private var thirdLabel = UILabel()
    private var stackView: UIStackView = UIStackView()
    private var frameCounter = 0
    private let handPosePredictionInterval = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraAccess()
    }
    
    func checkCameraAccess() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            setupARView()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { enabled in
                DispatchQueue.main.async {
                    if enabled {
                        self.setupARView()
                    } else {
                        print("not working...")
                    }
                }
            }
        case .denied, .restricted:
            print("Check settings..")
        @unknown default:
            print("Error")
        }
    }
    
    func setupARView() {
        arView = ARSCNView(frame: view.bounds)
        arView.session.delegate = self
        view.addSubview(arView)
        
        let configuration = ARWorldTrackingConfiguration()
        
        if ARFaceTrackingConfiguration.isSupported {
            let faceTrackingConfig = ARFaceTrackingConfiguration()
            arView.session.run(faceTrackingConfig)
        } else {
            arView.session.run(configuration)
        }
        thirdLabel = UILabel(frame: .init(x: 0, y: 0, width: 300, height: 12))
        thirdLabel.text = ""
        thirdLabel.textColor = .black
        thirdLabel.font = .systemFont(ofSize: 26)
        thirdLabel.backgroundColor = .lightText
        thirdLabel.textAlignment  = .center
        
        label = UILabel(frame: .init(x: 0, y: 0, width: self.view.frame.width, height: 30))
        label.text = labelText
        label.textColor = .white
        label.font = .systemFont(ofSize: 65)
        
        stackView = .init(frame: .init(x: 0, y: 40, width: (self.view.frame.width), height: 200))
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.addArrangedSubview(secondLabel)
        stackView.addArrangedSubview(thirdLabel)
        stackView.spacing = 2
        stackView.layoutMargins = .init(top: 10, left: 30, bottom: 10, right: 30)
        
        view.addSubview(stackView)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        frameCounter += 1
        guard frameCounter % handPosePredictionInterval == 0 else { return }

        let pixelBuffer = frame.capturedImage

        Task {
            let cgImage = convertCIImageToCGImage(CIImage(cvPixelBuffer: pixelBuffer))
            guard let cgImage else { return }

            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }

                let handPoseRequest = VNDetectHumanHandPoseRequest()
                handPoseRequest.maximumHandCount = 1
                handPoseRequest.revision = VNDetectContourRequestRevision1

                autoreleasepool {
                    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                    do {
                        try handler.perform([handPoseRequest])
                    } catch {
                        print("Human Pose Request failed: \(error.localizedDescription)")
                        return
                    }

                    guard
                        let handObservations = handPoseRequest.results?.first
                    else { return }

                    guard
                        let keypointsMultiArray = try? handObservations.keypointsMultiArray()
                    else { return }

                    do {
                        let config = MLModelConfiguration()
                        config.computeUnits = .cpuAndGPU
                        let model = try HandPoseClassifier(configuration: config)
                        let handPosePrediction = try model.prediction(poses: keypointsMultiArray)

                        let confidence = handPosePrediction.labelProbabilities[handPosePrediction.label] ?? 0.0
                        
                        let label = handPosePrediction.label

                        DispatchQueue.main.async {
                            self.thirdLabel.text = "\(self.convertToPercentage(confidence))%"
                            if confidence > 0.85 {
                                self.labelText = label
                            }
                        }
                    } catch {
                        print("Failure HandyModel: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func cleanEmojii() {
        
        DispatchQueue.main.async {
            self.labelText = ""
            self.secondLabel.text = ""
        }
    }
    
    @MainActor
    private func convertCIImageToCGImage(_ ciImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        return context.createCGImage(ciImage, from: ciImage.extent)
    }
    
    private func convertToPercentage(_ value: Double) -> Float {
        let result = Int((value * 1000))
        return Float(result) / 10
    }
}

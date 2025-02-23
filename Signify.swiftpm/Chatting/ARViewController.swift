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
    private var resetTimer: Timer?
    var alphabetText: String = "" {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.alphabetLabel.text = (self.alphabetLabel.text ?? "") + self.alphabetText
                
                self.resetTimer?.invalidate()
                self.resetTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.cleanSubtitle), userInfo: nil, repeats: false)
                let maxWidth = self.view.frame.width * 0.5
                let maxSize = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
                let estimatedSize = self.alphabetLabel.sizeThatFits(maxSize)
                
                self.alphabetLabel.constraints.forEach { constraint in
                    if constraint.firstAttribute == .height {
                        constraint.constant = estimatedSize.height + 20 // 여백 추가
                    }
                }
            }
        }
    }
    
    private var alphabetLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.layer.masksToBounds = true
        label.numberOfLines = 0
        label.layer.cornerRadius = 10
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
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
        view.addSubview(alphabetLabel)
        
        NSLayoutConstraint.activate([
            alphabetLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            alphabetLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            alphabetLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            alphabetLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 50) // 🔹 최소 높이 설정
        ])
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
                            if confidence > 0.88 {
                                self.alphabetText = label
                            }
                        }
                    } catch {
                        print("Failure HandyModel: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    @objc
    private func cleanSubtitle() {
        DispatchQueue.main.async {
            self.alphabetText = ""
            self.alphabetLabel.text = ""
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

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
                
                if self.alphabetText.isEmpty {
                    self.alphabetLabel.isHidden = true
                } else {
                    self.alphabetLabel.isHidden = false
                    self.alphabetLabel.text = (self.alphabetLabel.text ?? "") + self.alphabetText
                    
                    self.resetTimer?.invalidate()
                    self.resetTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.cleanSubtitle), userInfo: nil, repeats: false)
                    
                    let maxWidth = self.view.frame.width * 0.5
                    let maxSize = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
                    let estimatedSize = self.alphabetLabel.sizeThatFits(maxSize)
                    
                    let padding: CGFloat = 10
                    let labelWidth = min(estimatedSize.width + padding * 2, maxWidth)
                    let labelHeight = estimatedSize.height + padding * 2
                    
                    self.alphabetLabel.frame = CGRect(
                        x: (self.view.frame.width - labelWidth) / 2 - 10,
                        y: self.view.frame.height - labelHeight - 40,
                        width: labelWidth,
                        height: labelHeight
                    )
                }
            }
        }
    }
    private var alphabetLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.font = UIFont.preferredFont(forTextStyle: .title2)
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
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        if isARViewSetup {
//            setupARView()
//        }
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        arView.session.pause()
    }
    
    @MainActor
    func checkCameraAccess() {
        Task {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
                case .authorized:
                   setupARView()
                case .notDetermined:
                    let isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
                    if isAuthorized {
                        setupARView()
                    } else {
                        print("Camera access denied")
                    }
                case .denied, .restricted:
                    print("Check settings..")
                @unknown default:
                    print("Error")
            }
        }
    }
    
    @MainActor
    func setupARView() {
        arView = ARSCNView(frame: view.bounds)
        arView.session.delegate = self
        view.addSubview(arView)
        
        //        let cameraFrame = CGRect(
        //            x: 0,                y: 0,
        //            width: view.frame.width * 2 / 3,
        //            height: view.frame.height
        //        )
        //        arView.frame = cameraFrame
        
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
            alphabetLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -view.frame.width / 4),
            alphabetLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            alphabetLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.5)
        ])
    }
    private func setLabel() {
        
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

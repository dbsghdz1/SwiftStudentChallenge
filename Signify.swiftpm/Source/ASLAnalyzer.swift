//
//  ASLAnalyzer.swift
//  Signify
//
//  Created by 김윤홍 on 1/28/25.
//

import Vision
import UIKit

final class ASLAnalyzer {
    
    private var requests = [VNRequest]()
    
    @MainActor
    func setupVision()/* -> NSError?*/ {
        // Setup Vision parts
        let error: NSError! = nil
        
        guard let modelURL = Bundle.main.url(forResource: "MyHandPoseClassifier", withExtension: "mlmodelc") else {
            return /*NSError(domain: "VisionObjectRecognitionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])*/
        }
        
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                DispatchQueue.main.async(execute: {
                    // perform all the UI updates on the main queue
                    if let results = request.results {
                        print(results)
                    }
                })
            })
            self.requests = [objectRecognition]
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
        
//        return error
    }
    
//    func setupVision() {
//        
//    }
}

//
//  DetectionResult.swift
//  Signify
//
//  Created by 김윤홍 on 1/27/25.
//
import AVFoundation
import Vision

struct DetectionResult: Hashable {
    let identifier: String
    let confidence: VNConfidence
    let boundingBox: CGRect
}

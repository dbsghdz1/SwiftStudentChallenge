//
//  CameraPreview.swift
//  Signify
//
//  Created by 김윤홍 on 2/3/25.
//

import UIKit
import AVFoundation

class CameraPreview: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("CameraPreview's layer is not an AVCaptureVideoPreviewLayer")
        }
        return layer
    }
}

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
        return layer as! AVCaptureVideoPreviewLayer
    }
}

//
//  CameraPreviewView.swift
//  Signify
//
//  Created by 김윤홍 on 2/3/25.
//

import SwiftUI
import AVFoundation

@available(iOS 17.0, *)
struct CameraPreviewView: UIViewRepresentable {
    let cameraService: CameraService
    
    func makeUIView(context: Context) -> CameraPreview {
        return cameraService.preview
    }
    
    func updateUIView(_ uiView: CameraPreview, context: Context) {
        
    }
}

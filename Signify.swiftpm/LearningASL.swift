//
//  LearningASL.swift
//  Signify
//
//  Created by 김윤홍 on 2/21/25.
//

import SwiftUI

@available(iOS 17.0, *)
struct LearningASL: View {
    private let cameraService = CameraService()
    let id: String
    let content: String
    
    var body: some View {
        HStack {
            CameraPreviewView(cameraService: cameraService)
                .frame(width: UIScreen.main.bounds.width / 2)
                .clipped()
            
            ASLScriptView()
                .frame(maxWidth: .infinity)
        }
        .onAppear {
            Task {
                await cameraService.setCamera()
            }
        }
    }
}

struct ViewContent: Hashable {
    let id: String
    let content: String
}

import SwiftUI
import Vision
import CoreML

struct ContentView: View {
    
    @State var cameraPreviewView: CameraPreviewView
    
    var body: some View {
        VStack {
            cameraPreviewView
                .ignoresSafeArea()
                .onAppear(perform: {
                    Task {
                        await cameraPreviewView.setCamera()
                    }
                })
        }
    }
}

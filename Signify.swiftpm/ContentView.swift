import SwiftUI

struct ContentView: View {
    
    private let cameraService = CameraService()
    var body: some View {
        VStack {
            CameraPreviewView(cameraService: cameraService)
                .ignoresSafeArea()
        }
        .onAppear {
            Task {
                await cameraService.setCamera()
            }
        }
    }
}

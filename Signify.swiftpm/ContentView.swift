import SwiftUI
import Combine

struct ContentView: View {
    
    @ObservedObject var cameraService = CameraService()
    
    var body: some View {
        ZStack {
            VStack {
                CameraPreviewView(cameraService: cameraService)
                    .ignoresSafeArea()
            }
            Text(cameraService.alphabet)
        }
        .onAppear {
            Task {
                await cameraService.setCamera()
            }
        }
    }
}

import SwiftUI
import Combine

@available(iOS 17.0, *)
struct ContentView: View {
    
    @ObservedObject var cameraService = CameraService()
    @StateObject var voiceService = VoiceService()
    
    var body: some View {
        ZStack {
            
            CameraPreviewView(cameraService: cameraService)
            
            HStack {
                Text(cameraService.alphabet)
                    .background(Color.black)
                Text(voiceService.transcript)
                    .background(Color.black)
            }
        }
        .onAppear {
            Task {
                await cameraService.setCamera()
                voiceService.startSpeaking()
            }
        }
    }
}

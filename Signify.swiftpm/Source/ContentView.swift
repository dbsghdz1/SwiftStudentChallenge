import SwiftUI
import Vision
import CoreML

struct ContentView: View {
    
    @State private var capturedImage : UIImage? = nil
    @State private var isCustomCameraViewPresented = false
    
    var body: some View {
        VStack {
            Text("")
        }
    }
}

#Preview {
    ContentView()
}


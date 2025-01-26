import SwiftUI
import Vision
import CoreML

struct ContentView: View {
  
  @State private var capturedImage : UIImage? = nil
  @State private var isCustomCameraViewPresented = false
  let checkImage = CheckImage()
  
  var body: some View {
    ZStack {
      if let uiImage = capturedImage {
        if let image = CIImage(image: uiImage) {
          Text(checkImage.checkImage(image: image))
        }
      } else {
        Color(UIColor.systemBackground)
      }
      VStack{
        Spacer()
        Button(action: {isCustomCameraViewPresented.toggle()}, label: {Image(systemName: "camera.fill").font(.largeTitle).padding().background(Color.black).foregroundColor(.white).clipShape(Circle())}).padding(.bottom).sheet(isPresented: $isCustomCameraViewPresented, content: {CustomCameraView(capturedImage: $capturedImage)})
        // 실시간으로 카메라 영상이 보이는 화면 표시
      }
    }
    
  }
}

#Preview {
  ContentView()
}

class CheckImage {
  func checkImage(image: CIImage) -> String {
    var result = "not hotdog"
    guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
      fatalError("Loading CoreMl Model Failed")
    }
    
    let request = VNCoreMLRequest(model: model) { request, error in
      guard let results = request.results as? [VNClassificationObservation] else { return }
      print(results)
      if let firstResult = results.first {
        if firstResult.identifier.contains("hotdog") {
          result = "hotDog"
        }
      }
    }
    let handler = VNImageRequestHandler(ciImage: image)
    
    do {
      try handler.perform([request])
    } catch {
      print(error)
    }
    return result
  }
}

//
//  CustomCameraView.swift
//  Signify
//
//  Created by 김윤홍 on 1/26/25.
//

import SwiftUI

struct CustomCameraView : View {
  let cameraService = CameraService()
  @Binding var capturedImage : UIImage?
  
  @Environment(\.presentationMode) private var presentationMode
  
  var body: some View{
    ZStack{
      CameraView(cameraService: cameraService) { result in
        switch result{
          case .success(let photo):
            if let data = photo.fileDataRepresentation(){
              // 사진 버튼을 누르면 아래와 같이 동작
              capturedImage = UIImage(data : data)
              presentationMode.wrappedValue.dismiss()
            } else {
              print("Error : no image data found")
            }
          case .failure(let err):
            print(err.localizedDescription)
        }
      }
      VStack{
        Spacer()
        Button(action: {
          cameraService.capturePhoto()
        }, label: {Image(systemName: "circle").font(.system(size: 72)).foregroundColor(.white)})
      }
    }
  }
}

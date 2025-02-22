//
//  SwiftUIView.swift
//  Signify
//
//  Created by 김윤홍 on 2/21/25.
//

import SwiftUI

struct ASLScriptView: View {
    var body: some View {
        VStack {
            Text("Aa")
                .font(.largeTitle)
            Text("🤔")
                .font(Font.system(size: 72))
            Text("Follow the hand shapes below to learn the alphabet!")
            Image("")
            Button {
                print("next word")
            } label: {
                Text("Next Word")
            }
//            .background(Color.black)
            
            Button {
                print("previous word")
            } label: {
                Text("Previous Word")
            }

        }
    }
}

#Preview {
    ASLScriptView()
}

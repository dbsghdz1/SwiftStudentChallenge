//
//  LearningASL.swift
//  Signify
//
//  Created by 김윤홍 on 2/21/25.
//

import SwiftUI

@available(iOS 17.0, *)
struct LearningASL: View {
    let id: String
    let content: String
    @State private var alphabet: String = ""
    var body: some View {
        HStack(spacing: 0) {
            ARViewContainer(alphabet: $alphabet, isLearningMode: true)
                .frame(width: UIScreen.main.bounds.width * 0.5)
                .clipped()
            
            ASLScriptView(alphabet: $alphabet, id: self.id)
                .frame(width: UIScreen.main.bounds.width * 0.5)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ViewContent: Hashable {
    let id: String
    let content: String
}

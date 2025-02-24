//
//  MainScreen.swift
//  Signify
//
//  Created by 김윤홍 on 2/17/25.
//

import SwiftUI

enum Pages: String, Hashable {
    case chat, learn, howToUse
}

struct MainScreen: View {
    @State var currentPage: Pages = .chat
    var body: some View {
        
        if #available(iOS 18.0, *) {
            TabView(selection: $currentPage) {
                
                Tab("Chat", systemImage: "video", value: .chat) {
                    ContentView()
                }
                
                Tab("Learn ASL", systemImage: "book", value: .learn) {
                    LearningScreen()
                }
                
                Tab("How to Use", systemImage: "questionmark.text.page", value: .howToUse) {
                    HowToUse()
                }
            }
        }
    }
}

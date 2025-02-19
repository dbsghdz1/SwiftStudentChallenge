//
//  MainScreen.swift
//  Signify
//
//  Created by 김윤홍 on 2/17/25.
//

import SwiftUI

enum Pages: String, Hashable {
    case home, camera, onboarding
}

struct MainScreen: View {
    @State var currentPage: Pages = .home
    
    var body: some View {
        
        if #available(iOS 18.0, *) {
            TabView(selection: $currentPage) {
                
                Tab("Home", systemImage: "video", value: .home) {
                    Text("home1")
                }
                
                Tab("Learn ASL", systemImage: "book", value: .home) {
                    Text("Learn ASL")
                }
                
                Tab("How to Use", systemImage: "questionmark.text.page", value: .home) {
                    Text("home")
                }
            }
            .tabViewStyle(.sidebarAdaptable)
            .tabViewSidebarHeader {
                Label("Signify", systemImage: "person.crop.circle")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}

//
//  HowToUse.swift
//  Signify
//
//  Created by 김윤홍 on 2/23/25.
//

import SwiftUI

struct HowToUse: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("How to Use")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                
                Text("Signify is a communication app designed for conversations with friends.\nIt is especially tailored for people who are deaf or nonverbal, allowing them to communicate without relying on paper or pens.")
                    .padding(.horizontal)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Chat with Your Friend!")
                        .font(.title2)
                        .bold()
                    
                    Text("When using the Chat tab, the person signing should be positioned on the **left**, while the person speaking should be on the **right**.")
                    
                    Image("ChatImage")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Learn ASL!")
                        .font(.title2)
                        .bold()
                    
                    Text("You can study the ASL alphabet from **A to Z** and practice each letter’s hand shape.")
                    
                    Image("LearnASL")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
            }
            .padding(.vertical, 20)
        }
    }
}

#Preview {
    
}

//
//  LearningScreen.swift
//  Signify
//
//  Created by 김윤홍 on 2/21/25.
//

import SwiftUI

struct LearningScreen: View {
    
    private let alphabets = (0..<26).map { i in
        let letter = String(UnicodeScalar(65 + i)!)
        return "\(letter)\(letter.lowercased())"
    }
    
    @State private var path: [ViewContent] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading) {
                Text("Learning ASL")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 20)], spacing: 40) {
                        ForEach(alphabets, id: \.self) { alphabet in
                            AlphabetCells(alphabet: alphabet)
                                .onTapGesture {
                                    path.append(ViewContent(id: alphabet, content: alphabet))
                                }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationDestination(for: ViewContent.self) { next in
                if #available(iOS 17.0, *) {
                    LearningASL(id: next.id, content: next.content)
                } 
            }
        }
    }
}

struct AlphabetCells: View {
    let alphabet: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(white: 0.9))
                .frame(width: 180, height: 180)
            Text(self.alphabet)
                .font(.system(size: 40))
                .padding()
        }
    }
}

struct LearningScreen_Previews: PreviewProvider {
    static var previews: some View {
        LearningScreen()
    }
}


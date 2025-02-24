//
//  AlphabetCells.swift
//  Signify
//
//  Created by 김윤홍 on 2/24/25.
//

import SwiftUI

struct AlphabetCells: View {
    let alphabet: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.green.opacity(0.6))
                .blur(radius: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.green.opacity(0.5), lineWidth: 1)
                        .shadow(color: Color.green.opacity(0.2), radius: 10, x: 0, y: 5)
                )
                .frame(width: 180, height: 180)
            
            Text(self.alphabet)
                .font(.system(size: 40))
                .bold()
                .foregroundColor(.white)
        }
    }
}

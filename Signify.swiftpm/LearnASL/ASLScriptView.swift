//
//  SwiftUIView.swift
//  Signify
//
//  Created by 김윤홍 on 2/21/25.
//

import SwiftUI

struct ASLScriptView: View {
    @Binding var alphabet: String
    private let ASLDescription = [
        "A": "Make a fist with your thumb resting on the side of your index finger. The palm faces forward.",
        "B": "Extend all four fingers straight up and together, while the thumb rests against the palm. The palm faces forward.",
        "C": "Curve your fingers and thumb to form a “C” shape. The palm faces sideways.",
        "D": "Extend your index finger straight up while keeping the other fingers curled into the palm. The thumb touches the tip of the middle finger, forming a small circle. The palm faces forward.",
        "E": "Curve all fingers toward the palm, with the tips of the fingers touching the thumb. The palm faces forward.",
        "F": "Form a circle by touching the tip of the index finger to the tip of the thumb. Extend the other three fingers straight up. The palm faces forward.",
        "G": "Extend the index finger and thumb horizontally, as if pinching something. The remaining fingers stay curled in the palm. The palm faces sideways.",
        "H": "Extend both the index and middle fingers straight, keeping them together. The thumb holds down the ring and pinky fingers. The palm faces sideways.",
        "I": "Make a fist with your hand, then extend only the pinky finger straight up. The palm faces forward.",
        "J": "Start with the I handshape, then trace a “J” shape in the air with your pinky finger. The palm faces forward.",
        "K": "Extend the index and middle fingers in a “V” shape. The thumb touches the base of the middle finger. The palm faces forward.",
        "L": "Extend the index finger straight up and the thumb straight out, forming an “L” shape. The remaining fingers stay curled. The palm faces forward.",
        "M": "Make a fist while tucking the thumb under the index, middle, and ring fingers. The pinky rests on the outside. The palm faces forward.",
        "N": "Similar to “M,” but the thumb is tucked under only the index and middle fingers, with the ring and pinky fingers resting on the outside. The palm faces forward.",
        "O": "Bring all fingertips together to form a round “O” shape. The palm faces forward.",
        "P": " Similar to “K,” but the hand is tilted downward so the fingers point down. The palm faces sideways.",
        "Q": "Similar to “G,” but the hand is tilted downward so the fingers point down. The palm faces sideways.",
        "R": "Cross the index and middle fingers over each other. The thumb holds down the ring and pinky fingers. The palm faces forward.",
        "S": "Make a fist, with the thumb resting over the front of the fingers. The palm faces forward.",
        "T": "Make a fist but tuck the thumb between the index and middle fingers. The palm faces forward.",
        "U": "Extend both the index and middle fingers straight up and together. The thumb holds down the ring and pinky fingers. The palm faces forward.",
        "V": "Extend both the index and middle fingers straight up in a “V” shape. The thumb holds down the ring and pinky fingers. The palm faces forward.",
        "W": "Extend the index, middle, and ring fingers straight up while keeping them slightly spread apart. The thumb holds down the pinky finger. The palm faces forward.",
        "X": "Curl the index finger slightly to form a hook shape, while the thumb rests against the side of the hand. The other fingers stay curled. The palm faces forward.",
        "Y": "Extend the thumb and pinky finger out, while the other three fingers remain curled into the palm. The palm faces forward.",
        "Z": "Make a fist and extend your thumb to point upwards at a 45-degree angle.",
        "Default": "SomeThing Error"
    ]
    
    var id: String
    var body: some View {
        VStack(spacing: 15) {
            Text(self.id)
                .font(Font.system(size: 80))
            Text("😀")
                .font(Font.system(size: 72))
            Text("👉 Follow the hand shapes below to learn the alphabet!\n")
            Text(ASLDescription["\(self.id.prefix(1))"] ?? "Default")
                .padding(.horizontal)
            Image(String(self.id.prefix(1)))
                .frame(width: 300, height: 400)
        }
    }
}

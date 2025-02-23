import SwiftUI

struct ContentView: View {
    
    @State private var alphabet: String = ""
    @StateObject private var voiceService = VoiceService()
    
    var body: some View {
        ZStack {
            ARViewContainer(alphabet: $alphabet)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    Text(voiceService.subtitle)
                        .padding()
                        .foregroundStyle(.white)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        .font(.title2)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.5)
                        .padding(.horizontal, 10)
                }
                .padding(.bottom, 20) 
            }
        }
        .onAppear {
            voiceService.startSpeaking()
        }
    }
}

import SwiftUI

struct ContentView: View {
    
    @State private var labelText: String = ""
    var body: some View {
        
        ZStack {
            ARViewContainer(labelText: $labelText)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
            }
            .padding()
        }

    }
}

#Preview {
    ContentView()
}

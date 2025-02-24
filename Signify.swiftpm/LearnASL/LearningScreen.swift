import SwiftUI

struct LearningScreen: View {
    
    private let alphabets = (0..<26).map { i in
        let letter = String(UnicodeScalar(65 + i)!)
        return "\(letter)\(letter.lowercased())"
    }
    
    @State private var path: [ViewContent] = []
    
    var body: some View {
        
        NavigationStack(path: $path) {
            ZStack {
                BlurView(style: .systemUltraThinMaterial)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    Text("Learning ASL")
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .foregroundColor(.black)

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
                .padding()
            }
            .navigationDestination(for: ViewContent.self) { next in
                if #available(iOS 17.0, *) {
                    LearningASL(id: next.id, content: next.content)
                }
            }
        }
    }
}

struct LearningScreen_Previews: PreviewProvider {
    static var previews: some View {
        LearningScreen()
    }
}

import SwiftUI

@main
struct MyApp: App {
    
    var body: some Scene {
        WindowGroup {
            if #available(iOS 17.0, *) {
                MainScreen()
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

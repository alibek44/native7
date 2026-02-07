import SwiftUI
import FirebaseCore 

@main
struct WeatherApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

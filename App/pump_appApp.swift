import SwiftUI
import FirebaseCore

@main
struct PumpApp: App {  // ← ИЗМЕНИТЕ НА PumpApp (с большой P)
    @StateObject private var authService = AuthService()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
        }
    }
}

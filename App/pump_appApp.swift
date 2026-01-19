// pump_appApp.swift
import SwiftUI
import FirebaseCore
import GoogleSignIn // [!code focus]

@main
struct pump_appApp: App {
    @StateObject private var authService = AuthService()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            AuthenticationView()
                .environmentObject(authService)
                .onOpenURL { url in // [!code focus]
                    // Обработка URL, полученных от Google Sign-In[citation:8]
                    GIDSignIn.sharedInstance.handle(url) // [!code focus]
                } // [!code focus]
        }
    }
}

//
//  pump_apApp.swift
//  pump_ap
//
//  Created by Кирилл on 30.10.2025.
//

import SwiftUI

@main
struct pump_apApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}

// App/MainTabView.swift
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authService: AuthService
    @StateObject private var trainingViewModel: TrainingViewModel
    @StateObject private var profileViewModel: ProfileViewModel
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    init() {
        // Создаем trainingService для TrainingViewModel
        let trainingService = TrainingService()
        _trainingViewModel = StateObject(wrappedValue: TrainingViewModel(trainingService: trainingService))
        
        // Создаем authService для ProfileViewModel
        let authService = AuthService()
        _profileViewModel = StateObject(wrappedValue: ProfileViewModel(authService: authService))
    }
    
    var body: some View {
        TabView {
            NavigationView {
                HomeView()
                    .environmentObject(trainingViewModel)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Главная")
            }
            
            NavigationView {
                TrainingCalendarView()
                    .environmentObject(trainingViewModel)
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Календарь")
            }
            
            NavigationView {
                ChatListView()
            }
            .tabItem {
                Image(systemName: "message.fill")
                Text("Чаты")
            }
            
            NavigationView {
                ProfileView()
                    .environmentObject(profileViewModel)
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Профиль")
            }
            
            NavigationView {
                SettingsView()
                    .environmentObject(settingsViewModel)
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Настройки")
            }
        }
        .accentColor(.blue)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthService())
    }
}

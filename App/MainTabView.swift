import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authService: AuthService
    @StateObject private var trainingViewModel: TrainingViewModel
    @StateObject private var profileViewModel: ProfileViewModel
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    // ДОБАВЬТЕ эту переменную
    @StateObject private var trainingService: TrainingService
    
    init() {
        // СОЗДАЕМ trainingService как StateObject
        let trainingService = TrainingService()
        _trainingService = StateObject(wrappedValue: trainingService)
        
        // Передаем его в TrainingViewModel
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
                    // ИСПОЛЬЗУЙТЕ ОДИНАКОВЫЕ ЭКЗЕМПЛЯРЫ:
                    .environmentObject(trainingService)        // ← тот же trainingService
                    .environmentObject(trainingViewModel)      // ← тот же trainingViewModel
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

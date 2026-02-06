import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authService: AuthService
    @StateObject private var trainingViewModel = TrainingViewModel()
    @StateObject private var profileViewModel: ProfileViewModel
    @State private var selectedTab = 0
    @State private var showingTrainingDetail = false
    @State private var selectedTraining: Training?
    
    init() {
        let authService = AuthService()
        _profileViewModel = StateObject(wrappedValue: ProfileViewModel(authService: authService))
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                HomeView(selectedTab: $selectedTab)
                    .environmentObject(trainingViewModel)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Главная")
            }
            .tag(0)
            
            NavigationView {
                TrainingCalendarView()
                    .environmentObject(trainingViewModel)
                    .onAppear {
                        // Проверяем сохраненную тренировку при каждом появлении календаря
                        if let trainingData = UserDefaults.standard.data(forKey: "selectedTraining"),
                           let training = try? JSONDecoder().decode(Training.self, from: trainingData) {
                            selectedTraining = training
                            showingTrainingDetail = true
                            // Очищаем сохраненные данные
                            UserDefaults.standard.removeObject(forKey: "selectedTraining")
                        }
                    }
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Календарь")
            }
            .tag(1)
            
            NavigationView {
                ChatsListView()
            }
            .tabItem {
                Label("Чаты", systemImage: "message.fill")
            }
            
            NavigationView {
                CareerView()
            }
            .tabItem {
                Image(systemName: "figure.run")
                Text("Спорт")
            }
            
            NavigationView {
                ProfileView()
                    .environmentObject(profileViewModel)
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Профиль")
            }
            
        }
        .accentColor(.blue)
        .sheet(isPresented: $showingTrainingDetail) {
            if let training = selectedTraining {
                TrainingDetailView(training: training)
                    .environmentObject(trainingViewModel) // Добавляем environmentObject
            }
        }
        .onAppear {
            // Очищаем все сохраненные данные при запуске приложения
            UserDefaults.standard.removeObject(forKey: "selectedCalendarDate")
            UserDefaults.standard.removeObject(forKey: "showTrainingDetails")
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthService())
    }
}

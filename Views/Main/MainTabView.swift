import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var trainingManager = TrainingManager()
    
    var body: some View {
        TabView {
            NavigationView {
                HomeView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Главная")
            }
            
            NavigationView {
                TrainingCalendarView()
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
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Профиль")
            }
            
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Настройки")
            }
        }
        .accentColor(.blue)
        .environmentObject(trainingManager)
    }
}

struct HomeView: View {
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var trainingManager: TrainingManager
    
    @State private var userWeightData: [WeightData] = [
        WeightData(date: Date().addingTimeInterval(-6*24*3600), weight: 75.0),
        WeightData(date: Date().addingTimeInterval(-4*24*3600), weight: 74.5),
        WeightData(date: Date().addingTimeInterval(-2*24*3600), weight: 74.0),
        WeightData(date: Date(), weight: 73.5)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Greeting
                greetingView
                
                // Next workout reminder
                NextWorkoutCard()
                
                // Weight progress chart
                WeightProgressChart(weightData: userWeightData)
                
                // User balance
                BalanceCard()
            }
            .padding(.vertical, 10)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Главная")
    }
    
    private var greetingView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(getGreeting())
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Работайте над своими целями")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let greeting: String
        
        switch hour {
        case 6..<12:
            greeting = "Доброе утро"
        case 12..<18:
            greeting = "Добрый день"
        case 18..<24:
            greeting = "Добрый вечер"
        default:
            greeting = "Доброй ночи"
        }
        
        if let user = authManager.currentUser {
            return "\(greeting), \(user.displayName)!"
        } else {
            return "\(greeting)!"
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthManager())
    }
}

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authService: AuthService
    @StateObject private var trainingViewModel: TrainingViewModel
    @StateObject private var profileViewModel: ProfileViewModel
    @StateObject private var trainingService: TrainingService
    @State private var selectedTab: MainTab = .home

    init() {
        let trainingService = TrainingService()
        _trainingService = StateObject(wrappedValue: trainingService)
        _trainingViewModel = StateObject(wrappedValue: TrainingViewModel(trainingService: trainingService))
        let authService = AuthService()
        _profileViewModel = StateObject(wrappedValue: ProfileViewModel(authService: authService))
    }

    var body: some View {
        Group {
            if authService.currentUser?.role == .trainer {
                TrainerModeView()
            } else {
                clientTabs
            }
        }
        .accentColor(.blue)
    }

    private var clientTabs: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                HomeView {
                    selectedTab = .matching
                }
                    .environmentObject(trainingViewModel)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Главная")
            }
            .tag(MainTab.home)

            NavigationView {
                TrainerMatchingView()
                    .environmentObject(profileViewModel)
            }
            .tabItem {
                Image(systemName: "person.crop.rectangle.stack.fill")
                Text("Подбор")
            }
            .tag(MainTab.matching)

            NavigationView {
                TrainingCalendarView()
                    .environmentObject(trainingService)
                    .environmentObject(trainingViewModel)
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Календарь")
            }
            .tag(MainTab.calendar)

            NavigationView {
                ChatListView {
                    selectedTab = .matching
                }
            }
            .tabItem {
                Image(systemName: "message.fill")
                Text("Чаты")
            }
            .tag(MainTab.chats)

            NavigationView {
                ProfileView()
                    .environmentObject(profileViewModel)
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Профиль")
            }
            .tag(MainTab.profile)
        }
    }
}

private enum MainTab: Hashable {
    case home
    case matching
    case calendar
    case chats
    case profile
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthService())
    }
}

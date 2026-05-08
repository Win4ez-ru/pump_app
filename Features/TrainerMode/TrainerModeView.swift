import SwiftUI

struct TrainerModeView: View {
    @State private var selectedTab: TrainerTab = .requests

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                TrainerRequestsDashboard()
            }
            .tabItem {
                Image(systemName: "tray.full.fill")
                Text("Заявки")
            }
            .tag(TrainerTab.requests)

            NavigationView {
                TrainerScheduleDashboard()
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Календарь")
            }
            .tag(TrainerTab.calendar)

            NavigationView {
                TrainerChatsDashboard()
            }
            .tabItem {
                Image(systemName: "message.fill")
                Text("Чаты")
            }
            .tag(TrainerTab.chats)

            NavigationView {
                TrainerClientsDashboard()
            }
            .tabItem {
                Image(systemName: "person.2.fill")
                Text("Клиенты")
            }
            .tag(TrainerTab.clients)

            NavigationView {
                TrainerProfileDashboard()
            }
            .tabItem {
                Image(systemName: "person.crop.circle.fill")
                Text("Профиль")
            }
            .tag(TrainerTab.profile)
        }
    }
}

private enum TrainerTab: Hashable {
    case requests
    case calendar
    case chats
    case clients
    case profile
}

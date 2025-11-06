import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Text("Главная страница")
                .tabItem {
                    Image(systemName: "house")
                    Text("Главная")
                }
            
            Text("Профиль")
                .tabItem {
                    Image(systemName: "person")
                    Text("Профиль")
                }
            
            Text("Чаты")
                .tabItem {
                    Image(systemName: "message")
                    Text("Сообщения")
                }
        }
    }
}

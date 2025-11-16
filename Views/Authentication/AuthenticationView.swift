import SwiftUI

struct AuthenticationView: View {
    @StateObject private var authManager = AuthManager()
    @State private var isShowingSignUp = false
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                // Переходим к основному приложению
                MainTabView()
            } else {
                // Показываем экран входа
                LoginView(isShowingSignUp: $isShowingSignUp)
                    .sheet(isPresented: $isShowingSignUp) {
                        SignUpView()
                    }
            }
        }
        .environmentObject(authManager)
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}

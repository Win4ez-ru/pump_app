import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        Group {
            switch authManager.authState {
            case .authenticated, .guest:
                MainTabView()
                    .environmentObject(authManager)
            case .unauthenticated:
                LoginView(authManager: authManager)
                    .environmentObject(authManager)
            case .loading:
                LoadingView()
            }
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(AuthManager())
    }
}

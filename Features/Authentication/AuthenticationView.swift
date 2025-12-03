// Features/Authentication/AuthenticationView.swift
import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject private var authService: AuthService
    
    var body: some View {
        Group {
            switch authService.authState {
            case .authenticated, .guest:
                MainTabView()
                    .environmentObject(authService)
            case .unauthenticated:
                LoginView(authServiceParam: authService)
                    .environmentObject(authService)
            case .loading:
                LoadingView()
            }
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(AuthService())
    }
}

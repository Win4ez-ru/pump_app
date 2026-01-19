// GoogleSignInButtonView.swift
import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInButtonView: View {
    @EnvironmentObject private var authService: AuthService
    
    var body: some View {
        GoogleSignInButton(action: handleGoogleSignIn)
            .accessibilityLabel("Войти через Google")
    }
    
    private func handleGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("❌ Не найден Client ID Firebase")
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("❌ Не удалось получить root view controller")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            if let error = error {
                print("❌ Ошибка входа через Google: \(error.localizedDescription)")
                // Можно добавить отображение ошибки пользователю
                return
            }
            
            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                print("❌ Не удалось получить данные пользователя Google")
                return
            }
            
            // ИСПОЛЬЗУЕМ НОВЫЙ МЕТОД В AuthService ← ВАЖНОЕ ИЗМЕНЕНИЕ
            Task {
                do {
                    try await authService.signInWithGoogle(
                        idToken: idToken,
                        accessToken: user.accessToken.tokenString
                    )
                    print("✅ Успешный вход через Google")
                } catch {
                    print("❌ Ошибка входа через Google в AuthService: \(error.localizedDescription)")
                }
            }
        }
    }
}

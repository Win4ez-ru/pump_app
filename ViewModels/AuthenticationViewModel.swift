import Foundation
import Combine

class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @Published var confirmPassword = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    private let authManager: AuthManager
    
    init(authManager: AuthManager = AuthManager()) {
        self.authManager = authManager
    }
    
    var passwordsMatch: Bool {
        password == confirmPassword
    }
    
    var isSignUpFormValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        !username.isEmpty &&
        passwordsMatch &&
        password.count >= 6 &&
        email.contains("@")
    }
    
    var isLoginFormValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        email.contains("@")
    }
    
    func signUp() async -> Bool {
        guard isSignUpFormValid else {
            await MainActor.run {
                errorMessage = "Пожалуйста, заполните все поля правильно. Пароль должен быть не менее 6 символов."
            }
            return false
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = ""
        }
        
        do {
            try await authManager.signUp(email: email, password: password, username: username)
            await MainActor.run {
                errorMessage = ""
            }
            return true
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    func signIn() async -> Bool {
        guard isLoginFormValid else {
            await MainActor.run {
                errorMessage = "Пожалуйста, заполните все поля правильно"
            }
            return false
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = ""
        }
        
        do {
            try await authManager.signIn(email: email, password: password)
            await MainActor.run {
                errorMessage = ""
            }
            return true
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
            return false
        }
    }
}

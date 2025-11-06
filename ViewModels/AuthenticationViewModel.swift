import Foundation
import Combine

class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @Published var confirmPassword = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    private let authManager = AuthManager()
    
    var passwordsMatch: Bool {
        password == confirmPassword
    }
    
    var isSignUpFormValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        !username.isEmpty &&
        passwordsMatch &&
        password.count >= 6
    }
    
    var isLoginFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    func signIn() async -> Bool {
        guard isLoginFormValid else {
            errorMessage = "Пожалуйста, заполните все поля"
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await authManager.signIn(email: email, password: password)
            errorMessage = "" // Сбрасываем ошибку при успехе
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func signUp() async -> Bool {
        guard isSignUpFormValid else {
            errorMessage = "Пожалуйста, заполните все поля правильно"
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await authManager.signUp(email: email, password: password, username: username)
            errorMessage = "" // Сбрасываем ошибку при успехе
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}

import Foundation
import Combine

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var username = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    var isLoginFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    var isSignUpFormValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        !username.isEmpty &&
        password == confirmPassword
    }
    
    func signIn(authService: AuthService) async -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Заполните все поля"
            return false
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            try await authService.signIn(email: email, password: password)
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    func signUp(authService: AuthService) async -> Bool {
        guard isSignUpFormValid else {
            errorMessage = "Заполните все поля правильно"
            return false
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            try await authService.signUp(
                email: email,
                password: password,
                username: username
            )
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }
}

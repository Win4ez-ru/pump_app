import Foundation
import Combine
import FirebaseAuth

@MainActor
class AuthenticationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @Published var confirmPassword = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    // MARK: - Private Properties
    private let authManager: AuthManager
    
    // MARK: - Validation Properties
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
    
    var emailValidationMessage: String? {
        if email.isEmpty { return nil }
        return email.contains("@") ? nil : "Введите корректный email"
    }
    
    var passwordValidationMessage: String? {
        if password.isEmpty { return nil }
        return password.count >= 6 ? nil : "Пароль должен быть не менее 6 символов"
    }
    
    var confirmPasswordValidationMessage: String? {
        if confirmPassword.isEmpty { return nil }
        return passwordsMatch ? nil : "Пароли не совпадают"
    }
    
    // MARK: - Initialization
    init(authManager: AuthManager) {
        self.authManager = authManager
    }
    
    // MARK: - Authentication Methods
    func signUp() async -> Bool {
        guard isSignUpFormValid else {
            errorMessage = "Пожалуйста, заполните все поля правильно. Пароль должен быть не менее 6 символов."
            return false
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            try await authManager.signUp(email: email, password: password, username: username)
            clearForm()
            return true
        } catch {
            errorMessage = handleAuthError(error)
            return false
        }
    }
    
    func signIn() async -> Bool {
        guard isLoginFormValid else {
            errorMessage = "Пожалуйста, заполните все поля правильно"
            return false
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            try await authManager.signIn(email: email, password: password)
            clearForm()
            return true
        } catch {
            errorMessage = handleAuthError(error)
            return false
        }
    }
    
    // MARK: - Private Methods
    private func clearForm() {
        email = ""
        password = ""
        username = ""
        confirmPassword = ""
        isLoading = false
    }
    
    private func handleAuthError(_ error: Error) -> String {
        let nsError = error as NSError
        
        // Используем напрямую коды ошибок Firebase
        switch nsError.code {
        case 17007: // AuthErrorCode.emailAlreadyInUse
            return "Этот email уже используется"
        case 17008: // AuthErrorCode.invalidEmail
            return "Неверный формат email"
        case 17026: // AuthErrorCode.weakPassword
            return "Пароль слишком слабый"
        case 17009, 17011: // AuthErrorCode.wrongPassword, .userNotFound
            return "Неверный email или пароль"
        case 17020: // AuthErrorCode.networkError
            return "Ошибка сети. Проверьте подключение"
        default:
            return "Произошла ошибка: \(error.localizedDescription)"
        }
    }
}

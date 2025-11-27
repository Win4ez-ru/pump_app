import SwiftUI
import Combine  // Добавляем этот импорт

struct SignUpView: View {
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(authManager: AuthManager) {
        _viewModel = StateObject(wrappedValue: AuthenticationViewModel(authManager: authManager))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    headerView
                    
                    // Form
                    formView
                    
                    // Sign Up Button
                    AuthButton(
                        title: "Зарегистрироваться",
                        isLoading: viewModel.isLoading,
                        isEnabled: viewModel.isSignUpFormValid,
                        backgroundColor: .green
                    ) {
                        Task {
                            if await viewModel.signUp() {
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Error Message
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Components (без изменений)
    private var headerView: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 70))
                .foregroundColor(.green)
            
            Text("Создать аккаунт")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Заполните данные для регистрации")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.top, 30)
    }
    
    private var formView: some View {
        VStack(spacing: 18) {
            UsernameField(text: $viewModel.username)
            
            EmailField(
                title: "Email",
                text: $viewModel.email,
                validationMessage: viewModel.emailValidationMessage
            )
            
            PasswordField(
                title: "Пароль",
                text: $viewModel.password,
                validationMessage: viewModel.passwordValidationMessage
            )
            
            PasswordField(
                title: "Подтвердите пароль",
                text: $viewModel.confirmPassword,
                validationMessage: viewModel.confirmPasswordValidationMessage,
                showConfirmation: true
            )
        }
        .padding(.horizontal)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(authManager: AuthManager())
    }
}

import SwiftUI
import Combine

struct SignUpView: View {
    @EnvironmentObject private var authService: AuthService
    @StateObject private var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(authService: AuthService) {
        _viewModel = StateObject(wrappedValue: AuthenticationViewModel(authService: authService))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    headerView
                    
                    // Form
                    formView
                    
                    // Sign Up Button - ИСПРАВЛЯЕМ
                    PrimaryButton(
                        title: "Зарегистрироваться",
                        action: {
                            Task {
                                if await viewModel.signUp() {
                                    dismiss()
                                }
                            }
                        },
                        isLoading: viewModel.isLoading,
                        isDisabled: !viewModel.isSignUpFormValid,
                        backgroundColor: .green
                    )
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
    
    // MARK: - Components
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
            // ЗАМЕНЯЕМ кастомные поля на стандартные
            TextField("Имя пользователя", text: $viewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Пароль", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Подтвердите пароль", text: $viewModel.confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(authService: AuthService())
    }
}

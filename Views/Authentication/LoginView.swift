import SwiftUI
import Combine  // Добавляем этот импорт

struct LoginView: View {
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var viewModel: AuthenticationViewModel
    
    @State private var isShowingSignUp = false
    
    // Упрощенный инициализатор
    init(authManager: AuthManager) {
        _viewModel = StateObject(wrappedValue: AuthenticationViewModel(authManager: authManager))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    headerView
                    
                    // Form
                    formView
                    
                    // Login Button
                    AuthButton(
                        title: "Войти",
                        isLoading: viewModel.isLoading,
                        isEnabled: viewModel.isLoginFormValid
                    ) {
                        Task {
                            await viewModel.signIn()
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
                    
                    // Divider
                    dividerView
                    
                    // Guest Button
                    SecondaryButton(title: "Продолжить как гость") {
                        authManager.skipAuthentication()
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Sign Up Link
                    signUpLinkView
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isShowingSignUp) {
                SignUpView(authManager: authManager)
            }
        }
    }
    
    // MARK: - Components (без изменений)
    private var headerView: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Добро пожаловать")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Войдите в свой аккаунт")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.top, 40)
    }
    
    private var formView: some View {
        VStack(spacing: 20) {
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
        }
        .padding(.horizontal)
    }
    
    private var dividerView: some View {
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.3))
            
            Text("или")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 10)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.3))
        }
        .padding(.horizontal)
    }
    
    private var signUpLinkView: some View {
        HStack {
            Text("Нет аккаунта?")
                .foregroundColor(.secondary)
            
            Button {
                isShowingSignUp = true
            } label: {
                Text("Зарегистрироваться")
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
        .padding(.bottom, 30)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(authManager: AuthManager())
    }
}

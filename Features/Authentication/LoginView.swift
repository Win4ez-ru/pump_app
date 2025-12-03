import SwiftUI
import Combine

struct LoginView: View {
    @EnvironmentObject private var authService: AuthService
    @StateObject private var viewModel: AuthenticationViewModel
    
    @State private var isShowingSignUp = false
    
    // ПЕРЕИМЕНУЙ ПАРАМЕТР
    init(authServiceParam: AuthService) {
        _viewModel = StateObject(wrappedValue: AuthenticationViewModel(authService: authServiceParam))
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
                    PrimaryButton(
                        title: "Войти",
                        action: {
                            Task {
                                _ = await viewModel.signIn()
                            }
                        },
                        isLoading: viewModel.isLoading,
                        isDisabled: !viewModel.isLoginFormValid
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
                    
                    // Divider
                    dividerView
                    
                    // Guest Button
                    SecondaryButton(title: "Продолжить как гость") {
                        authService.skipAuthentication()
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Sign Up Link
                    signUpLinkView
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isShowingSignUp) {
                SignUpView(authService: authService)
            }
        }
    }
    
    // MARK: - Components
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
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Пароль", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
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
        LoginView(authServiceParam: AuthService())
    }
}

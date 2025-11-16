import SwiftUI

struct LoginView: View {
    @Binding var isShowingSignUp: Bool
    @StateObject private var viewModel: AuthenticationViewModel
    @EnvironmentObject private var authManager: AuthManager
    
    init(isShowingSignUp: Binding<Bool>, authManager: AuthManager = AuthManager()) {
        self._isShowingSignUp = isShowingSignUp
        self._viewModel = StateObject(wrappedValue: AuthenticationViewModel(authManager: authManager))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Заголовок
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
                    
                    // Форма входа
                    VStack(spacing: 20) {
                        // Поле email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("your@email.com", text: $viewModel.email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .textContentType(.emailAddress)
                                .disableAutocorrection(true)
                        }
                        
                        // Поле пароля
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Пароль")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            SecureField("Введите пароль", text: $viewModel.password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textContentType(.password)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Кнопка входа
                    Button {
                        Task {
                            await viewModel.signIn()
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Войти")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                    }
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .disabled(!viewModel.isLoginFormValid || viewModel.isLoading)
                    .opacity((!viewModel.isLoginFormValid || viewModel.isLoading) ? 0.6 : 1.0)
                    
                    // Сообщение об ошибке
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Разделитель
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
                    
                    // Кнопка пропуска регистрации
                    Button("Продолжить как гость") {
                        authManager.skipAuthentication()
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Ссылка на регистрацию
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
            .navigationBarHidden(true)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isShowingSignUp: .constant(false))
            .environmentObject(AuthManager())
    }
}

import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authManager: AuthManager
    
    init(authManager: AuthManager = AuthManager()) {
        self._viewModel = StateObject(wrappedValue: AuthenticationViewModel(authManager: authManager))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Заголовок
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
                    
                    // Форма регистрации
                    VStack(spacing: 18) {
                        // Поле имени пользователя
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Имя пользователя")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Придумайте имя", text: $viewModel.username)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
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
                            
                            SecureField("Не менее 6 символов", text: $viewModel.password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textContentType(.newPassword)
                        }
                        
                        // Поле подтверждения пароля
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Подтвердите пароль")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            SecureField("Повторите пароль", text: $viewModel.confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textContentType(.newPassword)
                            
                            if !viewModel.passwordsMatch && !viewModel.confirmPassword.isEmpty {
                                Text("Пароли не совпадают")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Кнопка регистрации
                    Button {
                        Task {
                            if await viewModel.signUp() {
                                dismiss()
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Зарегистрироваться")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                    }
                    .background(Color.green)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .disabled(!viewModel.isSignUpFormValid || viewModel.isLoading)
                    .opacity((!viewModel.isSignUpFormValid || viewModel.isLoading) ? 0.6 : 1.0)
                    
                    // Сообщение об ошибке
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
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(AuthManager())
    }
}

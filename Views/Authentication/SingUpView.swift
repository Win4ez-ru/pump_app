import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Создать аккаунт")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Форма регистрации
                VStack(spacing: 16) {
                    TextField("Имя пользователя", text: $viewModel.username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Пароль", text: $viewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    SecureField("Подтвердите пароль", text: $viewModel.confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if !viewModel.passwordsMatch && !viewModel.confirmPassword.isEmpty {
                        Text("Пароли не совпадают")
                            .foregroundColor(.red)
                            .font(.caption)
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
                    } else {
                        Text("Зарегистрироваться")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.isSignUpFormValid || viewModel.isLoading)
                
                // Сообщение об ошибке
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .padding()
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

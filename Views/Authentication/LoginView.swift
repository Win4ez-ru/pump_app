import SwiftUI

struct LoginView: View {
    @Binding var isShowingSignUp: Bool
    @StateObject private var viewModel = AuthenticationViewModel()
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Вход в приложение")
                    .font(.title)
                    .bold()
                
                // Форма входа
                VStack(spacing: 16) {
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Пароль", text: $viewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
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
                    } else {
                        Text("Войти")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.isLoginFormValid || viewModel.isLoading)
                
                // Сообщение об ошибке
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Ссылка на регистрацию
                Button {
                    isShowingSignUp = true
                } label: {
                    HStack {
                        Text("Нет аккаунта?")
                        Text("Зарегистрироваться")
                            .fontWeight(.semibold)
                    }
                }
            }
            .padding()
        }
    }
}

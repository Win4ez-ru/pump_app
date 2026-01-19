import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var authService: AuthService
    @StateObject private var viewModel = AuthenticationViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var fullName = ""
    @State private var usernameAvailability: UsernameAvailability = .notChecked
    
    enum UsernameAvailability {
        case notChecked, checking, available, taken
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Основная информация")) {
                    TextField("Email", text: $viewModel.email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    TextField("Имя пользователя", text: $viewModel.username)
                        .autocapitalization(.none)
                        .onChange(of: viewModel.username) { _ in
                            checkUsernameAvailability()
                        }
                    
                    // Индикатор доступности username
                    if !viewModel.username.isEmpty {
                        HStack {
                            switch usernameAvailability {
                            case .checking:
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Проверка...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            case .available:
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Доступно")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            case .taken:
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("Уже занято")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            case .notChecked:
                                EmptyView()
                            }
                        }
                    }
                    
                    TextField("Полное имя (необязательно)", text: $fullName)
                }
                
                Section(header: Text("Безопасность")) {
                    SecureField("Пароль", text: $viewModel.password)
                    SecureField("Подтвердите пароль", text: $viewModel.confirmPassword)
                }
                
                if !viewModel.errorMessage.isEmpty {
                    Section {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Регистрация")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Зарегистрироваться") {
                        Task {
                            await signUp()
                        }
                    }
                    .disabled(!viewModel.isSignUpFormValid || usernameAvailability == .taken)
                }
            }
        }
    }
    
    private func checkUsernameAvailability() {
        guard !viewModel.username.isEmpty else {
            usernameAvailability = .notChecked
            return
        }
        
        usernameAvailability = .checking
        
        Task {
            do {
                let isAvailable = try await authService.isUsernameAvailable(viewModel.username)
                usernameAvailability = isAvailable ? .available : .taken
            } catch {
                usernameAvailability = .notChecked
            }
        }
    }
    
    private func signUp() async {
            do {
                try await authService.signUp(
                    email: viewModel.email,
                    password: viewModel.password,
                    username: viewModel.username,
                    fullName: fullName.isEmpty ? nil : fullName
                )
                dismiss()
            } catch {
                viewModel.errorMessage = error.localizedDescription
            }
        }
}

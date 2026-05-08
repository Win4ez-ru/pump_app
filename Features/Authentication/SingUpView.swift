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
                    headerView
                    roleSelectionView
                    formView

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
            Image(systemName: viewModel.selectedRole == .trainer ? "figure.strengthtraining.traditional" : "person.badge.plus")
                .font(.system(size: 70))
                .foregroundColor(viewModel.selectedRole == .trainer ? .blue : .green)
            
            Text("Создать аккаунт")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Выберите роль один раз. От нее зависит интерфейс приложения.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 30)
    }

    private var roleSelectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Тип аккаунта")
                .font(.headline)

            HStack(spacing: 12) {
                RoleSelectionCard(
                    title: "Клиент",
                    subtitle: "Подбор тренера, прогресс, чаты",
                    icon: "person.fill",
                    color: .green,
                    isSelected: viewModel.selectedRole == .client
                ) {
                    viewModel.selectedRole = .client
                }

                RoleSelectionCard(
                    title: "Тренер",
                    subtitle: "Заявки, клиенты, календарь",
                    icon: "figure.strengthtraining.traditional",
                    color: .blue,
                    isSelected: viewModel.selectedRole == .trainer
                ) {
                    viewModel.selectedRole = .trainer
                }
            }

            Text("Поменять роль позже нельзя: для другого сценария нужен отдельный аккаунт.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
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

struct RoleSelectionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)

                    Spacer()

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? color : .secondary.opacity(0.5))
                }

                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(isSelected ? color.opacity(0.12) : Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? color : Color(.systemGray4), lineWidth: isSelected ? 1.5 : 1)
            )
            .cornerRadius(14)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(authService: AuthService())
    }
}

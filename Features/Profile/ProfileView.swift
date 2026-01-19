import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthService
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showingEditProfile = false
    @State private var showingPrivacySettings = false
    @State private var showingPayments = false
    
    private var user: User? {
        authManager.currentUser
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile header
                profileHeaderView
                
                // User balance
                BalanceCard()
                
                // Основные настройки (ВЗЯТО ИЗ SETTINGSVIEW)
                VStack(alignment: .leading, spacing: 15) {
                    Text("Основные")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    SettingsRow(
                        icon: "bell.fill",
                        title: "Уведомления",
                        subtitle: "Настройка уведомлений",
                        hasSwitch: true,
                        isOn: $viewModel.isNotificationsEnabled
                    )
                    
                    SettingsRow(
                        icon: "eye.fill",
                        title: "Приватность",
                        subtitle: "Настройки конфиденциальности"
                    )
                    .onTapGesture {
                        showingPrivacySettings = true
                    }
                    
                    SettingsRow(
                        icon: "paintbrush.fill",
                        title: "Тема",
                        subtitle: "Светлая / Темная",
                        hasSwitch: true,
                        isOn: $viewModel.isDarkModeEnabled
                    )
                }
                
                // Аккаунт (ВЗЯТО ИЗ SETTINGSVIEW)
                VStack(alignment: .leading, spacing: 15) {
                    Text("Аккаунт")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    SettingsRow(
                        icon: "person.fill",
                        title: "Данные аккаунта",
                        subtitle: "Изменить email, пароль"
                    )
                    .onTapGesture {
                        showingEditProfile = true
                    }
                    
                    SettingsRow(
                        icon: "creditcard.fill",
                        title: "Платежи",
                        subtitle: "Способы оплаты"
                    )
                    .onTapGesture {
                        showingPayments = true
                    }
                    
                    if authManager.hasSkippedLogin {
                        SettingsRow(
                            icon: "person.badge.plus",
                            title: "Зарегистрироваться",
                            subtitle: "Создать аккаунт",
                            color: .blue
                        )
                    }
                }
                
                // О приложении (ВЗЯТО ИЗ SETTINGSVIEW)
                VStack(alignment: .leading, spacing: 15) {
                    Text("О приложении")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    SettingsRow(
                        icon: "info.circle.fill",
                        title: "Версия",
                        subtitle: "1.0.0"
                    )
                    
                    SettingsRow(
                        icon: "shield.fill",
                        title: "Политика конфиденциальности",
                        subtitle: "Как мы используем ваши данные"
                    )
                    
                    SettingsRow(
                        icon: "doc.text.fill",
                        title: "Условия использования",
                        subtitle: "Правила сервиса"
                    )
                }
                
                // Информация о текущем режиме (ВЗЯТО ИЗ SETTINGSVIEW)
                if authManager.hasSkippedLogin {
                    VStack(spacing: 10) {
                        Text("Гостевой режим")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("Некоторые функции ограничены. Для полного доступа зарегистрируйтесь.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Logout button
                if authManager.isAuthenticated {
                    logoutButton
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Профиль")
        .onAppear {
            viewModel.loadSettings()
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showingPrivacySettings) {
            PrivacySettingsView()
        }
        .sheet(isPresented: $showingPayments) {
            PaymentsView()
        }
    }
    
    private var profileHeaderView: some View {
        VStack(spacing: 15) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(spacing: 5) {
                        Text(user?.displayName ?? "Гость")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        if let email = user?.email {
                            Text(email)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
            
            if authManager.hasSkippedLogin {
                Text("Гостевой режим")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    
    private var logoutButton: some View {
        Button(action: {
            try? authManager.signOut()
        }) {
            Text("Выйти")
                .font(.headline)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

// MARK: - SettingsRow (ВЗЯТО ИЗ SETTINGSVIEW)
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var hasSwitch: Bool = false
    var color: Color = .blue
    @Binding var isOn: Bool
    
    init(icon: String, title: String, subtitle: String, hasSwitch: Bool = false, color: Color = .blue, isOn: Binding<Bool> = .constant(true)) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.hasSwitch = hasSwitch
        self.color = color
        self._isOn = isOn
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if hasSwitch {
                Toggle("", isOn: $isOn)
                    .labelsHidden()
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}


// MARK: - Placeholder Views
struct PaymentsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Управление платежами")
                    .foregroundColor(.secondary)
                Spacer()
            }
            .navigationTitle("Платежи")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Редактирование профиля")
                    .foregroundColor(.secondary)
                Spacer()
            }
            .navigationTitle("Редактировать профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PrivacySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Настройки приватности")
                    .foregroundColor(.secondary)
                Spacer()
            }
            .navigationTitle("Приватность")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
                .environmentObject(AuthService())
        }
    }
}

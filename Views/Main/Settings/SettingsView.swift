import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authManager: AuthManager
    @AppStorage("isNotificationsEnabled") private var isNotificationsEnabled = true
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Basic settings
                basicSettingsSection
                
                // Account settings
                accountSettingsSection
                
                // About app
                aboutAppSection
                
                // Guest mode info
                if authManager.hasSkippedLogin {
                    guestModeInfo
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Настройки")
    }
    
    private var basicSettingsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Основные")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 1) {
                SettingsRow(
                    icon: "bell.fill",
                    title: "Уведомления",
                    subtitle: "Настройка уведомлений",
                    hasSwitch: true,
                    isOn: $isNotificationsEnabled
                )
                
                SettingsRow(
                    icon: "moon.fill",
                    title: "Темная тема",
                    subtitle: "Включить темный режим",
                    hasSwitch: true,
                    isOn: $isDarkModeEnabled
                )
                
                SettingsRow(
                    icon: "eye.fill",
                    title: "Приватность",
                    subtitle: "Настройки конфиденциальности"
                ) {
                    print("Открыть настройки приватности")
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var accountSettingsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Аккаунт")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 1) {
                SettingsRow(
                    icon: "person.fill",
                    title: "Данные аккаунта",
                    subtitle: "Изменить email, пароль"
                ) {
                    print("Открыть данные аккаунта")
                }
                
                SettingsRow(
                    icon: "creditcard.fill",
                    title: "Платежи",
                    subtitle: "Способы оплаты"
                ) {
                    print("Открыть платежи")
                }
                
                SettingsRow(
                    icon: "chart.bar.fill",
                    title: "Статистика",
                    subtitle: "Подробная аналитика"
                ) {
                    print("Открыть статистику")
                }
                
                if authManager.hasSkippedLogin {
                    SettingsRow(
                        icon: "person.badge.plus",
                        title: "Зарегистрироваться",
                        subtitle: "Создать аккаунт",
                        color: .blue
                    ) {
                        print("Переход к регистрации")
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var aboutAppSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("О приложении")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 1) {
                SettingsRow(
                    icon: "info.circle.fill",
                    title: "Версия",
                    subtitle: "1.0.0"
                )
                
                SettingsRow(
                    icon: "star.fill",
                    title: "Оценить приложение",
                    subtitle: "В App Store"
                ) {
                    print("Открыть App Store")
                }
                
                SettingsRow(
                    icon: "shield.fill",
                    title: "Политика конфиденциальности",
                    subtitle: "Как мы используем ваши данные"
                ) {
                    print("Открыть политику конфиденциальности")
                }
                
                SettingsRow(
                    icon: "doc.text.fill",
                    title: "Условия использования",
                    subtitle: "Правила сервиса"
                ) {
                    print("Открыть условия использования")
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var guestModeInfo: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            VStack(spacing: 6) {
                Text("Гостевой режим")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                Text("Некоторые функции ограничены. Для полного доступа ко всем возможностям приложения зарегистрируйтесь.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Settings Row Component
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var hasSwitch: Bool = false
    var color: Color = .blue
    var action: (() -> Void)?
    
    @Binding var isOn: Bool
    
    init(icon: String, title: String, subtitle: String, hasSwitch: Bool = false, color: Color = .blue, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.hasSwitch = hasSwitch
        self.color = color
        self.action = action
        self._isOn = Binding.constant(false)
    }
    
    init(icon: String, title: String, subtitle: String, hasSwitch: Bool = false, isOn: Binding<Bool>, color: Color = .blue) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.hasSwitch = hasSwitch
        self.color = color
        self._isOn = isOn
        self.action = nil
    }
    
    var body: some View {
        Button(action: { action?() }) {
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
                } else if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .disabled(action == nil && !hasSwitch)
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
                .environmentObject(AuthManager())
        }
    }
}

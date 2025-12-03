import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authService: AuthService
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Основные настройки
                VStack(alignment: .leading, spacing: 15) {
                    Text("Основные")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    SettingsRow(
                        icon: "bell.fill",
                        title: "Уведомления",
                        subtitle: "Настройка уведомлений",
                        hasSwitch: true
                    )
                    
                    SettingsRow(
                        icon: "eye.fill",
                        title: "Приватность",
                        subtitle: "Настройки конфиденциальности"
                    )
                    
                    SettingsRow(
                        icon: "paintbrush.fill",
                        title: "Тема",
                        subtitle: "Светлая / Темная"
                    )
                }
                
                // Аккаунт
                VStack(alignment: .leading, spacing: 15) {
                    Text("Аккаунт")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    SettingsRow(
                        icon: "person.fill",
                        title: "Данные аккаунта",
                        subtitle: "Изменить email, пароль"
                    )
                    
                    SettingsRow(
                        icon: "creditcard.fill",
                        title: "Платежи",
                        subtitle: "Способы оплаты"
                    )
                    
                    if authService.hasSkippedLogin {
                        SettingsRow(
                            icon: "person.badge.plus",
                            title: "Зарегистрироваться",
                            subtitle: "Создать аккаунт",
                            color: .blue
                        )
                    }
                }
                
                // О приложении
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
                
                // Информация о текущем режиме
                if authService.hasSkippedLogin {
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
            }
            .padding(.vertical)
        }
        .navigationTitle("Настройки")
    }
}

// Компонент строки настроек
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var hasSwitch: Bool = false
    var color: Color = .blue
    
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
                Toggle("", isOn: .constant(true))
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthService())
    }
}

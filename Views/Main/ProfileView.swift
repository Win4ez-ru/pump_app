import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Заголовок профиля
                VStack(spacing: 15) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    if let user = authManager.user {
                        VStack(spacing: 5) {
                            Text(user.username ?? "Пользователь")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(user.email)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("Гость")
                            .font(.title2)
                            .fontWeight(.semibold)
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
                
                // Информация о статусе
                VStack(alignment: .leading, spacing: 15) {
                    Text("Информация")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    InfoRow(icon: "calendar", title: "Дата регистрации", value: authManager.user?.createdAt.formatted(date: .abbreviated, time: .omitted) ?? "Неизвестно")
                    
                    InfoRow(icon: "person.fill", title: "Тип аккаунта", value: authManager.hasSkippedLogin ? "Гость" : "Зарегистрированный")
                    
                    InfoRow(icon: "shield.fill", title: "Статус", value: "Активный")
                }
                
                // Действия
                VStack(alignment: .leading, spacing: 15) {
                    Text("Действия")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if authManager.hasSkippedLogin {
                        ActionButton(
                            title: "Зарегистрироваться",
                            icon: "person.badge.plus",
                            color: .blue,
                            action: {
                                // Здесь будет переход к регистрации
                                print("Переход к регистрации")
                            }
                        )
                    }
                    
                    ActionButton(
                        title: "Редактировать профиль",
                        icon: "pencil",
                        color: .green,
                        action: {
                            print("Редактирование профиля")
                        }
                    )
                    
                    ActionButton(
                        title: "Настройки приватности",
                        icon: "lock.fill",
                        color: .purple,
                        action: {
                            print("Настройки приватности")
                        }
                    )
                }
                .padding(.top, 10)
                
                // Кнопка выхода
                if authManager.isAuthenticated {
                    Button {
                        try? authManager.signOut()
                    } label: {
                        Text("Выйти")
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                
                Spacer()
            }
        }
        .navigationTitle("Профиль")
    }
}

// Компонент строки информации
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

// Компонент кнопки действия
struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthManager())
    }
}

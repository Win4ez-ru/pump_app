import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthService
    @State private var showingEditProfile = false
    @State private var showingPrivacySettings = false
    
    private var user: User? {
        authManager.currentUser
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile header
                profileHeaderView
                
                // Statistics
                statisticsView
                
                // Account info
                accountInfoView
                
                // Actions
                actionsView
                
                // Logout button
                if authManager.isAuthenticated {
                    logoutButton
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Профиль")
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showingPrivacySettings) {
            PrivacySettingsView()
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
    
    private var statisticsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Статистика")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 15) {
                StatCard(
                    title: "Тренировок",
                    value: "12",
                    icon: "dumbbell",
                    color: .blue
                )
                
                StatCard(
                    title: "Часов",
                    value: "24",
                    icon: "clock",
                    color: .green
                )
                
                StatCard(
                    title: "Дней подряд",
                    value: "7",
                    icon: "flame",
                    color: .orange
                )
            }
            .padding(.horizontal)
        }
    }
    
    private var accountInfoView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Информация об аккаунте")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 1) {
                InfoRow(
                    icon: "calendar",
                    title: "Дата регистрации",
                    value: user?.createdAt.formatted(date: .abbreviated, time: .omitted) ?? "Неизвестно"
                )
                
                InfoRow(
                    icon: "person.fill",
                    title: "Тип аккаунта",
                    value: authManager.hasSkippedLogin ? "Гость" : "Зарегистрированный"
                )
                
                InfoRow(
                    icon: "shield.fill",
                    title: "Статус",
                    value: "Активный"
                )
            }
            .padding(.horizontal)
        }
    }
    
    private var actionsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Действия")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 1) {
                if authManager.hasSkippedLogin {
                    ActionRow(
                        title: "Зарегистрироваться",
                        icon: "person.badge.plus",
                        color: .blue
                    ) {
                        // Navigation to registration
                        print("Переход к регистрации")
                    }
                }
                
                ActionRow(
                    title: "Редактировать профиль",
                    icon: "pencil",
                    color: .green
                ) {
                    showingEditProfile = true
                }
                
                ActionRow(
                    title: "Настройки приватности",
                    icon: "lock.fill",
                    color: .purple
                ) {
                    showingPrivacySettings = true
                }
                
                ActionRow(
                    title: "Справка и поддержка",
                    icon: "questionmark.circle",
                    color: .gray
                ) {
                    print("Открыть справку")
                }
            }
            .padding(.horizontal)
        }
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

// MARK: - Supporting Views
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

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
    }
}

struct ActionRow: View {
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
        }
    }
}

// MARK: - Placeholder Views
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

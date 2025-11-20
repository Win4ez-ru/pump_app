import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var trainingManager = TrainingManager()
    
    var body: some View {
        TabView {
            NavigationView {
                HomeView()
                    .environmentObject(trainingManager)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Главная")
            }
            
            NavigationView {
                TrainingCalendarView()
                    .environmentObject(trainingManager)
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Календарь")
            }
            
            // Вкладка "Профиль"
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Профиль")
            }
            
            // Вкладка "Чаты"
            NavigationView {
                ChatListView()
            }
            .tabItem {
                Image(systemName: "message.fill")
                Text("Чаты")
            }
            
            // Вкладка "Настройки"
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Настройки")
            }
        }
        .accentColor(.blue)
    }
}

// Главный экран
struct HomeView: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var userWeightData: [WeightData] = [
        WeightData(date: Date().addingTimeInterval(-6*24*3600), weight: 75.0),
        WeightData(date: Date().addingTimeInterval(-4*24*3600), weight: 74.5),
        WeightData(date: Date().addingTimeInterval(-2*24*3600), weight: 74.0),
        WeightData(date: Date(), weight: 73.5)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) { // Уменьшил spacing с 24 до 20
                // Приветствие
                VStack(alignment: .leading, spacing: 6) { // Уменьшил spacing с 8 до 6
                    Text(getGreeting(for: authManager.user))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Работайте над своими целями")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 10) // Добавил небольшой верхний отступ вместо большого
                
                // Напоминание о следующей тренировке
                NextWorkoutCard()
                
                // График прогресса веса
                WeightProgressChart(weightData: userWeightData)
                
                // Баланс пользователя
                BalanceCard()
            }
            .padding(.vertical, 10) // Уменьшил с 20 до 10
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Главная")
    }
    
    private func getGreeting(for user: User?) -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let greeting: String
        
        switch hour {
        case 6..<12:
            greeting = "Доброе утро"
        case 12..<18:
            greeting = "Добрый день"
        case 18..<24:
            greeting = "Добрый вечер"
        default:
            greeting = "Доброй ночи"
        }
        
        if let user = authManager.user {
            return "\(greeting), \(user.username ?? user.email)!"
        } else {
            return "\(greeting)!"
        }
    }
}

// Карточка следующей тренировки
struct NextWorkoutCard: View {
    @EnvironmentObject private var trainingManager: TrainingManager
    @State private var showingCalendar = false
    
    private var nextTraining: Training? {
        trainingManager.nextTraining
    }
    
    var body: some View {
        Button(action: {
            showingCalendar = true
        }) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "bolt.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .cornerRadius(8)
                    
                    if let training = nextTraining {
                        Text("Следующая тренировка")
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text(formattedTime(training.startTime))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    } else {
                        Text("Тренировки")
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("Нет запланированных")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let training = nextTraining {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(training.title)
                            .font(.body)
                            .fontWeight(.medium)
                        
                        if !training.description.isEmpty {
                            Text(training.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 16) {
                            Label("\(training.exerciseCount) упр.", systemImage: "dumbbell")
                            Label("\(training.duration) мин", systemImage: "clock")
                            
                            if !training.trainer.isEmpty {
                                Label(training.trainer, systemImage: "person.fill")
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Тренировка не запланирована")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("Добавьте первую тренировку в календарь")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
        .sheet(isPresented: $showingCalendar) {
            TrainingCalendarView()
                .environmentObject(trainingManager)
        }
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

// График прогресса веса
struct WeightProgressChart: View {
    let weightData: [WeightData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.caption)
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(LinearGradient(
                        colors: [.green, .mint],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .cornerRadius(8)
                
                Text("Прогресс веса")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(String(format: "%.1f", weightData.last?.weight ?? 0)) кг")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            }
            
            // Минималистичный график
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(weightData) { data in
                    VStack(spacing: 8) {
                        // Линия прогресса
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                            .frame(width: 4, height: CGFloat(data.weight - 72) * 8)
                            .cornerRadius(2)
                        
                        Text("\(String(format: "%.0f", data.weight))")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 80)
            .padding(.vertical, 8)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}

// Карточка баланса
struct BalanceCard: View {
    @State private var balance: Double = 1250.50
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "creditcard")
                    .font(.caption)
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .cornerRadius(8)
                
                Text("Баланс")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(String(format: "%.0f", balance)) ₽")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            Button(action: {
                print("Пополнить баланс")
            }) {
                HStack {
                    Image(systemName: "plus")
                        .font(.caption.weight(.medium))
                    Text("Пополнить")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}

// Модель для данных веса
struct WeightData: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthManager())
    }
}

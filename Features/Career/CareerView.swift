import SwiftUI

struct CareerView: View {
    @StateObject private var viewModel = CareerViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Уровень и прогресс
                levelSection
                    .padding(.horizontal)
                
                // Селектор периода и статистика вместе
                VStack(spacing: 0) {
                    periodSelector
                    periodStatsSection
                }
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Топ за месяц
                topUsersSection
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Моя карьера")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Секция уровня
    
    private var levelSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Иконка уровня
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: .blue.opacity(0.3), radius: 10)
                    
                    Image(systemName: "trophy.fill")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Text("\(viewModel.stats.level)") // ← ИСПРАВЛЕНО: было viewModel.currentlevel
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .offset(y: 25)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Уровень \(viewModel.stats.level)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(viewModel.stats.experience) XP")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Прогресс-бар
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("До уровня \(viewModel.stats.level + 1)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(viewModel.stats.experience) XP")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        
                        ProgressView(value: viewModel.experienceProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
    }
    
    // MARK: - Селектор периода
    
    private var periodSelector: some View {
        VStack(spacing: 0) {
            // Полоска с текстами и кнопками
            ZStack(alignment: .leading) {
                // Фон полоски
                Capsule()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 40)
                
                // Ползунок
                GeometryReader { geometry in
                    let width = geometry.size.width / CGFloat(TimePeriod.allCases.count)
                    let index = CGFloat(TimePeriod.allCases.firstIndex(of: viewModel.selectedTimePeriod) ?? 0)
                    
                    Capsule()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: width, height: 40)
                        .padding(2)
                        .offset(x: width * index - 2)
                        .animation(.spring(response: 0.3), value: viewModel.selectedTimePeriod)
                }
                
                // Тексты периодов поверх кнопок
                HStack(spacing: 0) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.selectedTimePeriod = period
                            }
                        }) {
                            Text(period.rawValue)
                                .font(.subheadline)
                                .fontWeight(viewModel.selectedTimePeriod == period ? .semibold : .medium)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .frame(height: 44)
            .padding(.horizontal, 4)
        }
        .padding(.top, 12)
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }
    
    // MARK: - Статистика за период
    
    private var periodStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок статистики
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                    .font(.headline)
                
                Text(getPeriodTitle(for: viewModel.selectedTimePeriod))
                    .font(.headline)
                
                Spacer()
            }
            .padding(.top, 6)
            .padding(.horizontal, 16)
            
            // Сетка статистики
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                CareerStatCard(
                    title: "Тренировок",
                    value: "\(viewModel.currentPeriodStats.trainings)",
                    icon: "dumbbell.fill",
                    color: .blue,
                    unit: ""
                )
                
                CareerStatCard(
                    title: "Часов",
                    value: String(format: "%.1f", viewModel.currentPeriodStats.hours),
                    icon: "clock.fill",
                    color: .green,
                    unit: "ч"
                )
                
                CareerStatCard(
                    title: "Калорий",
                    value: "\(viewModel.currentPeriodStats.calories)",
                    icon: "flame.fill",
                    color: .orange,
                    unit: "ккал"
                )
                
                CareerStatCard(
                    title: "Интенсивность",
                    value: String(format: "%.1f", viewModel.currentPeriodStats.intensity),
                    icon: "bolt.fill",
                    color: .purple,
                    unit: "/10"
                )
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            
            // Дополнительная статистика
            VStack(spacing: 10) {
                HStack {
                    Label("Средняя тренировка", systemImage: "timer")
                        .font(.subheadline)
                    Spacer()
                    Text("\(viewModel.currentPeriodStats.avgSessionDuration) мин")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Label("Консистенция", systemImage: "chart.line.uptrend.xyaxis")
                        .font(.subheadline)
                    Spacer()
                    Text("\(Int(viewModel.stats.consistency))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(getConsistencyColor(viewModel.stats.consistency))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
    }
    
    // MARK: - Топ пользователей
    
    private var topUsersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Топ за месяц")
                    .font(.headline)
                
                Spacer()
                
                Text("по тренировкам")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 0) {
                ForEach(Array(viewModel.topUsers.enumerated()), id: \.element.id) { index, user in
                    HStack(spacing: 12) {
                        // Место
                        ZStack {
                            if index < 3 {
                                Circle()
                                    .fill(getRankColor(for: index))
                                    .frame(width: 28, height: 28)
                                
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            } else {
                                Text("\(index + 1)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                    .frame(width: 28)
                            }
                        }
                        
                        // Аватар
                        Circle()
                            .fill(colorFromString(user.avatarColorName))
                            .frame(width: 40, height: 40)
                        
                        // Имя и статистика
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(user.name)
                                    .font(.subheadline)
                                    .fontWeight(user.isCurrentUser ? .bold : .regular)
                                
                                if user.isCurrentUser {
                                    Text("(Вы)")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            HStack(spacing: 8) {
                                Label("\(user.trainings)", systemImage: "dumbbell")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Label("\(user.hours) ч", systemImage: "clock")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(user.isCurrentUser ?
                               Color.blue.opacity(0.1) : Color(.systemBackground))
                    
                    if index < viewModel.topUsers.count - 1 {
                        Divider()
                            .padding(.leading, 68)
                    }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Вспомогательные функции
    
    private func getPeriodTitle(for period: TimePeriod) -> String {
        switch period {
        case .day:
            return "Статистика за день"
        case .week:
            return "Статистика за неделю"
        case .month:
            return "Статистика за месяц"
        case .year:
            return "Статистика за год"
        }
    }
    
    private func getPeriodIcon(for period: TimePeriod) -> String {
        switch period {
        case .day: return "sun.max.fill"
        case .week: return "calendar"
        case .month: return "calendar.circle.fill"
        case .year: return "calendar.badge.clock"
        }
    }
    
    private func getConsistencyColor(_ consistency: Double) -> Color {
        switch consistency {
        case 90...100: return .green
        case 70..<90: return .blue
        case 50..<70: return .orange
        default: return .red
        }
    }
    
    private func getRankColor(for rank: Int) -> Color {
        switch rank {
        case 0: return .yellow
        case 1: return .gray
        case 2: return .orange
        default: return .blue
        }
    }
    
    private func colorFromString(_ colorName: String) -> Color {
        switch colorName {
        case "blue": return .blue
        case "pink": return .pink
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "red": return .red
        case "yellow": return .yellow
        default: return .gray
        }
    }
}

// MARK: - Улучшенный StatCard

struct CareerStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let unit: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 2)
        )
    }
}

struct CareerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CareerView()
        }
    }
}

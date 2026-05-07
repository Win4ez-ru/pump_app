import SwiftUI

struct CareerView: View {
    @StateObject private var viewModel = CareerViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Уровень и прогресс
                levelSection
                    .padding(.horizontal)

                healthSection
                    .padding(.horizontal)

                weeklyProgressSection
                    .padding(.horizontal)

                // Селектор периода и статистика вместе
                VStack(spacing: 0) {
                    periodSelector
                    periodStatsSection
                }
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(.separator).opacity(0.35), lineWidth: 0.5)
                )
                .padding(.horizontal)
                
                // Топ за месяц
                topUsersSection
                    .padding(.horizontal)

                achievementsSection
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Прогресс")
        .navigationBarTitleDisplayMode(.inline)

    }
    
    // MARK: - Секция уровня
    
    private var levelSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Иконка уровня
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "trophy.fill")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Text("\(viewModel.stats.level)")
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
                            
                            Text("\(Int(viewModel.experienceProgress * 100))%")
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
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(.separator).opacity(0.35), lineWidth: 0.5)
            )
        }
    }

    private var healthSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Сегодня")
                    .font(.headline)

                Spacer()

                Label("Health", systemImage: "heart.text.square.fill")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(viewModel.healthMetrics) { metric in
                    HealthProgressTile(metric: metric)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator).opacity(0.35), lineWidth: 0.5)
        )
    }

    private var weeklyProgressSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Неделя")
                    .font(.headline)

                Spacer()

                Text("цель: 3 тренировки")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(alignment: .bottom, spacing: 10) {
                ForEach(viewModel.weeklyProgress) { day in
                    WeeklyProgressBar(day: day)
                }
            }
            .frame(height: 96)

            HStack {
                Label("\(viewModel.stats.currentStreak) дней подряд", systemImage: "flame.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)

                Spacer()

                Text("лучшее: \(viewModel.stats.bestStreak)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator).opacity(0.35), lineWidth: 0.5)
        )
    }

    // MARK: - Селектор периода (цельная полоска с ползунком) - ИСПРАВЛЕН
    
    private var periodSelector: some View {
        VStack(spacing: 0) {
            // Полоска с текстами и кнопками - всё вместе
            ZStack(alignment: .leading) {
                // Фон полоски (почти прозрачный)
                Capsule()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 40)
                
                // Ползунок (не закрывает текст)
                GeometryReader { geometry in
                    let width = geometry.size.width / CGFloat(TimePeriod.allCases.count)
                    let index = CGFloat(TimePeriod.allCases.firstIndex(of: viewModel.selectedTimePeriod) ?? 0)
                    
                    Capsule()
                        .fill(Color(.systemBackground))
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
                                .contentShape(Rectangle()) // ← ВАЖНО: делает всю область кликабельной
                        }
                        .buttonStyle(PlainButtonStyle()) // ← Отключаем стандартный стиль кнопки
                    }
                }
            }
            .frame(height: 44)
            .padding(.horizontal, 4)
        }
        .padding(.top, 12) // ← УМЕНЬШИЛ отступ сверху
        .padding(.horizontal, 16)
        .padding(.bottom, 10) // ← ДОБАВИЛ отступ снизу, чтобы был ближе к статистике
    }
    
    // MARK: - Статистика за период (часть той же карточки) - УМЕНЬШИЛ ОТСТУПЫ
    
    private var periodStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) { // ← УМЕНЬШИЛ spacing с 16 до 12
            // Заголовок статистики
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                    .font(.headline)
                
                Text(getPeriodTitle(for: viewModel.selectedTimePeriod))
                    .font(.headline)
                
                Spacer()
            }
            .padding(.top, 6) // ← УМЕНЬШИЛ отступ сверху
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
            VStack(spacing: 10) { // ← УМЕНЬШИЛ spacing
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
            .padding(.vertical, 10) // ← УМЕНЬШИЛ вертикальные отступы
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .padding(.bottom, 12) // ← УМЕНЬШИЛ отступ снизу
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
                            .fill(user.avatarColor)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(String(user.name.prefix(1)))
                                    .font(.headline)
                                    .foregroundColor(.white)
                            )
                        
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
                               Color(.systemGray6) : Color(.systemBackground))
                    
                    if index < viewModel.topUsers.count - 1 {
                        Divider()
                            .padding(.leading, 68)
                    }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(.separator).opacity(0.35), lineWidth: 0.5)
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator).opacity(0.35), lineWidth: 0.5)
        )
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Достижения")
                    .font(.headline)

                Spacer()

                Text("\(viewModel.achievements.filter { $0.isUnlocked }.count)/\(viewModel.achievements.count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.achievements) { achievement in
                    AchievementCard(achievement: achievement)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator).opacity(0.35), lineWidth: 0.5)
        )
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
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
        )
    }
}

struct HealthProgressTile: View {
    let metric: HealthProgressMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Image(systemName: metric.icon)
                .font(.headline)
                .foregroundColor(metric.color)

            Text(metric.value)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(metric.title)
                .font(.caption)
                .foregroundColor(.secondary)

            ProgressView(value: metric.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: metric.color))

            Text("из \(metric.goal)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct WeeklyProgressBar: View {
    let day: WeeklyProgress

    var body: some View {
        VStack(spacing: 7) {
            Spacer()

            ZStack(alignment: .bottom) {
                Capsule()
                    .fill(Color.gray.opacity(0.16))
                    .frame(width: 22, height: 64)

                Capsule()
                    .fill(day.progress >= 1 ? Color.green : Color.blue)
                    .frame(width: 22, height: max(8, 64 * day.progress))
            }

            Text(day.day)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct AchievementCard: View {
    let achievement: Achievement

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: achievement.icon)
                    .font(.title3)
                    .foregroundColor(achievement.isUnlocked ? achievement.color : .gray)
                    .frame(width: 38, height: 38)
                    .background((achievement.isUnlocked ? achievement.color : Color.gray).opacity(0.12))
                    .clipShape(Circle())

                Spacer()

                Image(systemName: achievement.isUnlocked ? "checkmark.seal.fill" : "lock.fill")
                    .font(.caption)
                    .foregroundColor(achievement.isUnlocked ? .green : .secondary)
            }

            Text(achievement.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)

            Text(achievement.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            ProgressView(value: achievement.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: achievement.isUnlocked ? achievement.color : .gray))

            Text(achievement.isUnlocked ? "Получено" : "\(Int(achievement.progress * 100))%")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(achievement.isUnlocked ? .green : .secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 166, alignment: .topLeading)
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .opacity(achievement.isUnlocked ? 1 : 0.78)
    }
}


struct CareerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CareerView()
        }
    }
}

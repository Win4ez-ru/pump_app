import SwiftUI

// MARK: - Next Workout Card
struct NextWorkoutCard: View {
    @EnvironmentObject private var trainingManager: TrainingManager
    @State private var showingCalendar = false
    
    private var nextTraining: Training? {
        trainingManager.nextTraining
    }
    
    var body: some View {
        Button(action: { showingCalendar = true }) {
            VStack(alignment: .leading, spacing: 16) {
                headerView
                contentView
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
    
    private var headerView: some View {
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
    }
    
    @ViewBuilder
    private var contentView: some View {
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
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Weight Progress Chart
struct WeightProgressChart: View {
    let weightData: [WeightData]
    
    private var minWeight: Double {
        weightData.map(\.weight).min() ?? 0
    }
    
    private var maxWeight: Double {
        weightData.map(\.weight).max() ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            chartView
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
    
    private var headerView: some View {
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
            
            if let lastWeight = weightData.last {
                Text("\(String(format: "%.1f", lastWeight.weight)) кг")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            }
        }
    }
    
    private var chartView: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(weightData) { data in
                VStack(spacing: 8) {
                    // Progress line with relative height
                    let height = calculateBarHeight(for: data.weight)
                    
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .frame(width: 4, height: height)
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
    
    private func calculateBarHeight(for weight: Double) -> CGFloat {
        let range = max(maxWeight - minWeight, 1) // Avoid division by zero
        let normalized = (weight - minWeight) / range
        return CGFloat(normalized * 60) + 20 // Minimum height 20, maximum 80
    }
}

// MARK: - Balance Card
struct BalanceCard: View {
    @State private var balance: Double = 1250.50
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            topUpButton
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
    
    private var headerView: some View {
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
    }
    
    private var topUpButton: some View {
        Button(action: { print("Пополнить баланс") }) {
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
}

// MARK: - Data Models
struct WeightData: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
}

// Features/Home/Components/NextWorkoutCard.swift
import SwiftUI

struct NextWorkoutCard: View {
    var nextWorkout: Training? = nil
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
                
                Text("Следующая тренировка")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if nextWorkout != nil {
                    Text("Скоро")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(6)
                }
            }
            
            if let workout = nextWorkout {
                VStack(alignment: .leading, spacing: 6) {
                    Text(workout.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(workout.date.toString(format: "dd MMMM 'в' HH:mm"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        TrainingTypeBadge(type: workout.type)
                        
                        Spacer()
                        
                        Text("\(workout.exercises.count) упражнений")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "dumbbell.fill")
                        .font(.title2)
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("Тренировок не запланировано")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    SecondaryButton(title: "Запланировать", action: {
                        onTap?()
                    })
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 20)
        .onTapGesture {
            onTap?()
        }
    }
}

struct TrainingTypeBadge: View {
    let type: TrainingType
    
    var backgroundColor: Color {
        switch type {
        case .strength: return .orange.opacity(0.1)
        case .cardio: return .blue.opacity(0.1)
        case .yoga: return .green.opacity(0.1)
        case .stretching: return .purple.opacity(0.1)
        }
    }
    
    var foregroundColor: Color {
        switch type {
        case .strength: return .orange
        case .cardio: return .blue
        case .yoga: return .green
        case .stretching: return .purple
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(foregroundColor)
                .frame(width: 6, height: 6)
            
            Text(type.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(foregroundColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(backgroundColor)
        .cornerRadius(6)
    }
}

// MARK: - Previews
struct NextWorkoutCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            NextWorkoutCard(
                nextWorkout: Training(
                    id: "1",
                    title: "Силовая тренировка",
                    date: Date().addingTimeInterval(3600),
                    type: .strength,
                    exercises: [
                        Exercise(name: "Приседания", sets: 4, reps: 10, weight: 100),
                        Exercise(name: "Жим лежа", sets: 4, reps: 8, weight: 80)
                    ]
                ),
                onTap: {}
            )
            
            NextWorkoutCard(onTap: {})
        }
        .padding()
    }
}

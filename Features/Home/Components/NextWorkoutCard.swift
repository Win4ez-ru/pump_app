// Features/Home/Components/NextWorkoutCard.swift
import SwiftUI

struct NextWorkoutCard: View {
    let workout: Training
    let onTap: () -> Void
        
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Следующая тренировка")
                        .font(.headline)
                    
                    Text(workout.title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption)
                        
                        Text(formatDate(workout.date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
        
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM, HH:mm"
        return formatter.string(from: date)
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
                workout: Training(
                    id: "1",
                    title: "Силовая тренировка",
                    date: Date().addingTimeInterval(3600),
                    type: .strength
                ),
                onTap: { print("Нажато") }
            )
        }
        .padding()
    }
}

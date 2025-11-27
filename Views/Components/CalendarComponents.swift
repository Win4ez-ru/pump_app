import SwiftUI

struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let hasTraining: Bool
    let isCurrentMonth: Bool
    let isToday: Bool
    let onSelect: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 4) {
                ZStack {
                    // Background for today
                    if isToday {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 32, height: 32)
                    }
                    
                    // Background for selected date
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 32, height: 32)
                    }
                    
                    Text("\(calendar.component(.day, from: date))")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(isSelected ? .bold : .medium)
                        .foregroundColor(textColor)
                }
                .frame(height: 32)
                
                // Training indicator
                if hasTraining {
                    Circle()
                        .fill(isSelected ? Color.white : Color.orange)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(height: 44)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isCurrentMonth ? 1.0 : 0.3)
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .blue
        } else {
            return .primary
        }
    }
}

struct TrainingCardView: View {
    let training: Training
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(training.title)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("\(formattedTime(training.startTime)) - \(formattedTime(training.endTime))")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                // Actions menu
                Menu {
                    Button("Изменить", action: onEdit)
                    Button("Удалить", role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(.headline))
                        .foregroundColor(.secondary)
                }
            }
            
            // Training details
            VStack(alignment: .leading, spacing: 8) {
                if !training.description.isEmpty {
                    Text(training.description)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Statistics
                HStack(spacing: 16) {
                    Label("\(training.exerciseCount) упр.", systemImage: "dumbbell")
                    Label("\(training.duration) мин", systemImage: "clock")
                    
                    if !training.trainer.isEmpty {
                        Label(training.trainer, systemImage: "person.fill")
                    }
                }
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.secondary)
                
                // Notes
                if !training.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Заметки:")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        Text(training.notes)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct DragIndicator: View {
    let onTap: () -> Void
    
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.gray.opacity(0.4))
            .frame(width: 40, height: 6)
            .padding(.top, 8)
            .padding(.bottom, 4)
            .onTapGesture {
                onTap()
            }
    }
}

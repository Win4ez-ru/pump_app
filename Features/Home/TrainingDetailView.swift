import SwiftUI

struct TrainingDetailView: View {
    let training: Training
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var trainingViewModel: TrainingViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Заголовок
                    headerView
                        .padding(.horizontal)
                    
                    // Дата и время
                    dateTimeView
                        .padding(.horizontal)
                    
                    // Упражнения
                    if !training.exercises.isEmpty {
                        exercisesView
                    } else {
                        emptyExercisesView
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Редактировать") {
                        // Здесь можно открыть редактирование
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(training.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                TrainingTypeBadge(type: training.type)
            }
            
            Text(training.type.rawValue)
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    private var dateTimeView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                
                Text("Дата:")
                    .fontWeight(.medium)
                
                Text(formatDate(training.date))
            }
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                
                Text("Время:")
                    .fontWeight(.medium)
                
                Text(formatTime(training.date))
            }
        }
        .font(.body)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var exercisesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Упражнения")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            ForEach(training.exercises) { exercise in
                ExerciseDetailRow(exercise: exercise)
                    .padding(.horizontal)
            }
        }
    }
    
    private var emptyExercisesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "dumbbell")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Нет упражнений")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Добавьте упражнения в редакторе")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct ExerciseDetailRow: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(exercise.name)
                    .font(.headline)
                
                Spacer()
            }
            
            if let sets = exercise.sets, let reps = exercise.reps {
                HStack(spacing: 20) {
                    if sets > 0 {
                        DetailItem(icon: "repeat", text: "\(sets) подходов")
                    }
                    
                    if reps > 0 {
                        DetailItem(icon: "arrow.triangle.2.circlepath", text: "\(reps) повторений")
                    }
                    
                    if let weight = exercise.weight, weight > 0 {
                        DetailItem(icon: "scalemass", text: "\(Int(weight)) кг")
                    }
                    
                    if let duration = exercise.duration, duration > 0 {
                        DetailItem(icon: "clock", text: "\(duration) мин")
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct DetailItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
            
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

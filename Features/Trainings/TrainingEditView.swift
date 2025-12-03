// Features/Trainings/TrainingEditView.swift
import SwiftUI

struct TrainingEditView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TrainingViewModel
    let training: Training?
    
    @State private var title: String
    @State private var date: Date
    @State private var selectedType: TrainingType
    @State private var exercises: [Exercise]
    
    init(viewModel: TrainingViewModel, training: Training? = nil) {
        self.viewModel = viewModel
        self.training = training
        _title = State(initialValue: training?.title ?? "Новая тренировка")
        _date = State(initialValue: training?.date ?? Date())
        _selectedType = State(initialValue: training?.type ?? .strength)
        _exercises = State(initialValue: training?.exercises ?? [])
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Основная информация")) {
                    TextField("Название тренировки", text: $title)
                    
                    DatePicker("Дата и время", selection: $date)
                    
                    Picker("Тип тренировки", selection: $selectedType) {
                        ForEach(TrainingType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section(header: Text("Упражнения")) {
                    if exercises.isEmpty {
                        VStack {
                            Text("Нет упражнений")
                                .foregroundColor(.secondary)
                            Button("Добавить упражнение") {
                                addExercise()
                            }
                        }
                    } else {
                        ForEach(exercises.indices, id: \.self) { index in
                            SimpleExerciseRowView(
                                exercise: $exercises[index],
                                onDelete: { exercises.remove(at: index) }
                            )
                        }
                    }
                }
                
                Section {
                    Button("Добавить упражнение") {
                        addExercise()
                    }
                }
            }
            .navigationTitle(training == nil ? "Новая тренировка" : "Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveTraining()
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func addExercise() {
        // ЯВНО УКАЗЫВАЕМ ВСЕ ПАРАМЕТРЫ
        let newExercise = Exercise(
            id: UUID().uuidString,
            name: "Новое упражнение",
            sets: 3,
            reps: 10,
            weight: 0,
            duration: nil,
            intensity: nil
        )
        exercises.append(newExercise)
    }
    
    private func saveTraining() {
        let training = Training(
            id: training?.id ?? UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            date: date,
            type: selectedType,
            exercises: exercises
        )
        viewModel.saveTraining(training)
    }
}

struct SimpleExerciseRowView: View {
    @Binding var exercise: Exercise
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("Название упражнения", text: Binding(
                    get: { exercise.name },
                    set: { exercise.name = $0 }
                ))
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            if exercise.duration == nil {
                HStack {
                    TextField("Подходы", text: Binding(
                        get: { "\(exercise.sets ?? 0)" },
                        set: { exercise.sets = Int($0) ?? 0 }
                    ))
                    .keyboardType(.numberPad)
                    
                    TextField("Повторения", text: Binding(
                        get: { "\(exercise.reps ?? 0)" },
                        set: { exercise.reps = Int($0) ?? 0 }
                    ))
                    .keyboardType(.numberPad)
                    
                    TextField("Вес", text: Binding(
                        get: { "\(exercise.weight ?? 0)" },
                        set: { exercise.weight = Double($0) ?? 0 }
                    ))
                    .keyboardType(.decimalPad)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func updateExerciseName(_ newName: String) -> Exercise {
        return Exercise(
            id: exercise.id,
            name: newName,
            sets: exercise.sets,
            reps: exercise.reps,
            weight: exercise.weight,
            duration: exercise.duration,
            intensity: exercise.intensity
        )
    }
    
    private func updateExerciseSets(_ sets: String) -> Exercise {
        let setsValue = Int(sets) ?? 0
        return Exercise(
            id: exercise.id,
            name: exercise.name,
            sets: setsValue,
            reps: exercise.reps,
            weight: exercise.weight,
            duration: exercise.duration,
            intensity: exercise.intensity
        )
    }
    
    private func updateExerciseReps(_ reps: String) -> Exercise {
        let repsValue = Int(reps) ?? 0
        return Exercise(
            id: exercise.id,
            name: exercise.name,
            sets: exercise.sets,
            reps: repsValue,
            weight: exercise.weight,
            duration: exercise.duration,
            intensity: exercise.intensity
        )
    }
    
    private func updateExerciseWeight(_ weight: String) -> Exercise {
        let weightValue = Double(weight) ?? 0.0
        return Exercise(
            id: exercise.id,
            name: exercise.name,
            sets: exercise.sets,
            reps: exercise.reps,
            weight: weightValue,
            duration: exercise.duration,
            intensity: exercise.intensity
        )
    }
}

import SwiftUI

struct TrainingEditView: View {
    @State var training: Training
    let onSave: (Training) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate: Date
    @State private var startTime: Date
    @State private var endTime: Date
    
    init(training: Training, onSave: @escaping (Training) -> Void) {
        self._training = State(initialValue: training)
        self.onSave = onSave
        self._selectedDate = State(initialValue: training.date)
        self._startTime = State(initialValue: training.startTime)
        self._endTime = State(initialValue: training.endTime)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Основная информация")) {
                TextField("Название тренировки", text: $training.title)
                TextField("Описание", text: $training.description)
            }
            
            Section(header: Text("Дата и время")) {
                DatePicker("Дата", selection: $selectedDate, displayedComponents: .date)
                    .onChange(of: selectedDate) { newDate in
                        updateTrainingDate(newDate: newDate)
                    }
                
                DatePicker("Время начала", selection: $startTime, displayedComponents: .hourAndMinute)
                    .onChange(of: startTime) { newStartTime in
                        updateTrainingTimes(newStartTime: newStartTime, newEndTime: endTime)
                    }
                
                DatePicker("Время окончания", selection: $endTime, displayedComponents: .hourAndMinute)
                    .onChange(of: endTime) { newEndTime in
                        updateTrainingTimes(newStartTime: startTime, newEndTime: newEndTime)
                    }
            }
            
            Section(header: Text("Заметки")) {
                    TextEditor(text: $training.notes)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        .navigationTitle(training.title.isEmpty ? "Новая тренировка" : training.title)
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
                }
                .fontWeight(.semibold)
            }
        }
    }
    
    private func updateTrainingDate(newDate: Date) {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        
        if let newStartTime = calendar.date(bySettingHour: startComponents.hour ?? 0, minute: startComponents.minute ?? 0, second: 0, of: newDate),
           let newEndTime = calendar.date(bySettingHour: endComponents.hour ?? 0, minute: endComponents.minute ?? 0, second: 0, of: newDate) {
            
            training.date = newDate
            training.startTime = newStartTime
            training.endTime = newEndTime
            training.duration = calendar.dateComponents([.minute], from: newStartTime, to: newEndTime).minute ?? 60
        }
    }
    
    private func updateTrainingTimes(newStartTime: Date, newEndTime: Date) {
        let calendar = Calendar.current
        training.startTime = newStartTime
        training.endTime = newEndTime
        training.duration = calendar.dateComponents([.minute], from: newStartTime, to: newEndTime).minute ?? 60
    }
    
    private func saveTraining() {
        onSave(training)
        dismiss()
    }
}

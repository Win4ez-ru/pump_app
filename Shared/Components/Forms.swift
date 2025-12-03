// Shared/Components/Forms.swift
import SwiftUI

struct FormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var errorMessage: String? = nil
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(errorMessage != nil ? Color.red : Color.gray.opacity(0.3), lineWidth: 1)
            )
            
            if let error = errorMessage, !error.isEmpty {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 4)
            }
        }
    }
}

struct FormPicker<T: Hashable>: View {
    let title: String
    let options: [T]
    let optionTitles: [String]
    @Binding var selection: T
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Picker(title, selection: $selection) {
                ForEach(Array(zip(options, optionTitles)), id: \.0) { option, title in
                    Text(title).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 2)
        }
    }
}

struct DateFormField: View {
    let title: String
    @Binding var date: Date
    var displayedComponents: DatePickerComponents = [.date, .hourAndMinute]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            DatePicker("", selection: $date, displayedComponents: displayedComponents)
                .labelsHidden()
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct ValidationStateView: View {
    let isValid: Bool
    let message: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isValid ? .green : .red)
                .font(.caption)
            
            Text(message)
                .font(.caption)
                .foregroundColor(isValid ? .green : .red)
        }
    }
}

// MARK: - Previews
struct Forms_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            FormField(
                title: "Email",
                placeholder: "Введите ваш email",
                text: .constant(""),
                errorMessage: "Неверный формат email"
            )
            
            FormField(
                title: "Пароль",
                placeholder: "Введите пароль",
                text: .constant(""),
                isSecure: true
            )
            
            DateFormField(
                title: "Дата тренировки",
                date: .constant(Date())
            )
            
            ValidationStateView(
                isValid: true,
                message: "Пароль надежный"
            )
            
            ValidationStateView(
                isValid: false,
                message: "Пароль слишком короткий"
            )
        }
        .padding()
    }
}

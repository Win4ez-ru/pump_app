// Core/Utils/Helpers.swift
import Foundation
import SwiftUI

class Helpers {
    
    // MARK: - Date Helpers
    static func formatDate(_ date: Date, format: String = "dd.MM.yyyy HH:mm") -> String {
        date.toString(format: format)
    }
    
    static func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "Доброе утро"
        case 12..<18: return "Добрый день"
        case 18..<24: return "Добрый вечер"
        default: return "Доброй ночи"
        }
    }
    
    // MARK: - Validation Helpers
    static func validateEmail(_ email: String) -> Bool {
        email.isValidEmail()
    }
    
    static func validatePassword(_ password: String) -> Bool {
        password.count >= Constants.Validation.passwordMinLength
    }
    
    // MARK: - UI Helpers
    static func hapticFeedback() {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
    }
    
    // MARK: - Data Helpers
    static func decode<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
        try? JSONDecoder().decode(type, from: data)
    }
    
    static func encode<T: Encodable>(_ value: T) -> Data? {
        try? JSONEncoder().encode(value)
    }
}

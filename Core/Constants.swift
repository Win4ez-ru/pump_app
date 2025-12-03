// Core/Constants.swift
import Foundation

struct Constants {
    
    // MARK: - App
    struct App {
        static let appName = "PumpApp"
        static let version = "1.0.0"
    }
    
    // MARK: - Firestore
    struct Firestore {
        static let usersCollection = "users"
        static let trainingsCollection = "trainings"
        static let chatsCollection = "chats"
        static let messagesCollection = "messages"
        
        struct User {
            static let uid = "uid"
            static let email = "email"
            static let displayName = "displayName"
            static let photoURL = "photoURL"
            static let createdAt = "createdAt"
        }
        
        struct Training {
            static let id = "id"
            static let title = "title"
            static let date = "date"
            static let type = "type"
            static let exercises = "exercises"
        }
    }
    
    // MARK: - AppStorage
    struct AppStorage {
        static let isLoggedIn = "isLoggedIn"
        static let userSession = "userSession"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }
    
    // MARK: - Default Values
    struct Default {
        static let userDisplayName = "Пользователь"
        static let trainingTitle = "Новая тренировка"
    }
    
    // MARK: - Validation
    struct Validation {
        static let emailRegex = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        static let passwordMinLength = 6
    }
}

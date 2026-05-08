import Foundation

enum UserRole: String, Codable, Equatable {
    case client
    case trainer

    var title: String {
        switch self {
        case .client:
            return "Клиент"
        case .trainer:
            return "Тренер"
        }
    }
}

struct User: Identifiable, Codable, Equatable {
    let id: String
    let email: String
    let username: String?
    let role: UserRole
    let profileImageUrl: String?
    let createdAt: Date
    
    init(id: String, email: String, username: String? = nil, role: UserRole = .client, profileImageUrl: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.email = email
        self.username = username
        self.role = role
        self.profileImageUrl = profileImageUrl
        self.createdAt = createdAt
    }
    
    var displayName: String {
        username ?? email.components(separatedBy: "@").first ?? "Пользователь"
    }
    
    static let guest = User(
        id: "guest",
        email: "guest@example.com",
        username: "Гость"
    )
}

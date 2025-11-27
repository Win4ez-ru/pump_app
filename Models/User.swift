import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: String
    let email: String
    let username: String?
    let profileImageUrl: String?
    let createdAt: Date
    
    init(id: String, email: String, username: String? = nil, profileImageUrl: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.email = email
        self.username = username
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

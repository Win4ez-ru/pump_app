import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: String
    let email: String
    let username: String
    let fullName: String?
    let profileImageUrl: String?
    let createdAt: Date
    
    init(id: String, email: String, username: String, fullName: String? = nil, profileImageUrl: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.email = email
        self.username = username
        self.fullName = fullName
        self.profileImageUrl = profileImageUrl
        self.createdAt = createdAt
    }
    
    var displayName: String {
        fullName ?? username
    }
    
    static let guest = User(
        id: "guest",
        email: "guest@example.com",
        username: "Гость"
    )
}

import Foundation

struct User: Identifiable, Codable {
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
}

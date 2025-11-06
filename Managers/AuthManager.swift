import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var user: User?
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    init() {
        // Проверяем авторизацию при запуске
        if auth.currentUser != nil {
            isAuthenticated = true
        }
    }
    
    // Регистрация
    func signUp(email: String, password: String, username: String) async throws {
        let authResult = try await auth.createUser(withEmail: email, password: password)
        
        // Создаем запись пользователя в Firestore
        let newUser = User(
            id: authResult.user.uid,
            email: email,
            username: username
        )
        
        try await saveUserToFirestore(user: newUser)
        self.user = newUser
        self.isAuthenticated = true
    }
    
    // Вход
    func signIn(email: String, password: String) async throws {
        try await auth.signIn(withEmail: email, password: password)
        self.isAuthenticated = true
    }
    
    // Выход
    func signOut() throws {
        try auth.signOut()
        self.isAuthenticated = false
        self.user = nil
    }
    
    // Сохранение пользователя в Firestore
    private func saveUserToFirestore(user: User) async throws {
        let userData: [String: Any] = [
            "id": user.id,
            "email": user.email,
            "username": user.username ?? "",
            "createdAt": Timestamp(date: user.createdAt)
        ]
        
        try await db.collection("users").document(user.id).setData(userData)
    }
}

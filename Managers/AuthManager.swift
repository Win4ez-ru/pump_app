import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var user: User?
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private let defaults = UserDefaults.standard
    
    // Ключ для хранения состояния пропуска регистрации
    private let hasSkippedLoginKey = "hasSkippedLogin"
    
    var hasSkippedLogin: Bool {
        get {
            return defaults.bool(forKey: hasSkippedLoginKey)
        }
        set {
            defaults.set(newValue, forKey: hasSkippedLoginKey)
        }
    }
    
    init() {
        // Проверяем авторизацию при запуске
        if auth.currentUser != nil || hasSkippedLogin {
            isAuthenticated = true
            // Если пользователь пропустил регистрацию, создаем гостевого пользователя
            if hasSkippedLogin && auth.currentUser == nil {
                self.user = User(
                    id: "guest_\(UUID().uuidString)",
                    email: "guest@example.com",
                    username: "Гость"
                )
            } else if let currentUser = auth.currentUser {
                // Загружаем данные зарегистрированного пользователя
                Task {
                    await fetchUserData(userId: currentUser.uid)
                }
            }
        }
    }
    
    // Метод для пропуска регистрации
    func skipAuthentication() {
        hasSkippedLogin = true
        isAuthenticated = true
        
        // Создаем временного гостевого пользователя
        self.user = User(
            id: "guest_\(UUID().uuidString)",
            email: "guest@example.com",
            username: "Гость"
        )
    }
    
    // Регистрация
    func signUp(email: String, password: String, username: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
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
        self.hasSkippedLogin = false // Сбрасываем гостевой режим
    }
    
    // Вход
    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await auth.signIn(withEmail: email, password: password)
        self.isAuthenticated = true
        self.hasSkippedLogin = false // Сбрасываем гостевой режим
        
        // Загружаем данные пользователя
        if let currentUser = auth.currentUser {
            await fetchUserData(userId: currentUser.uid)
        }
    }
    
    // Выход
    func signOut() throws {
        try auth.signOut()
        hasSkippedLogin = false // Сбрасываем гостевой режим
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
    
    // Получение данных пользователя из Firestore
    private func fetchUserData(userId: String) async {
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            if let data = document.data() {
                let username = data["username"] as? String
                let email = data["email"] as? String ?? ""
                let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                
                await MainActor.run {
                    self.user = User(
                        id: userId,
                        email: email,
                        username: username,
                        createdAt: createdAt
                    )
                }
            }
        } catch {
            print("Error fetching user data: \(error)")
        }
    }
    
    // Для отслеживания состояния загрузки
    @Published var isLoading = false
}

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

// Расширение для сравнения AuthState должно быть БЕЗ "AuthService." префикса
extension AuthService.AuthState: Equatable {
    static func == (lhs: AuthService.AuthState, rhs: AuthService.AuthState) -> Bool {
        switch (lhs, rhs) {
        case (.authenticated(let user1), .authenticated(let user2)):
            return user1.id == user2.id
        case (.guest(let user1), .guest(let user2)):
            return user1.id == user2.id
        case (.unauthenticated, .unauthenticated):
            return true
        case (.loading, .loading):
            return true
        default:
            return false
        }
    }
}

@MainActor
class AuthService: ObservableObject {
    // MARK: - Published Properties
    @Published var authState: AuthState = .loading
    @Published var isLoading = false
    
    // MARK: - Private Properties
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private let defaults = UserDefaults.standard
    
    private let hasSkippedLoginKey = "hasSkippedLogin"
    
    // MARK: - Auth State
    enum AuthState {
        case authenticated(User)
        case unauthenticated
        case guest(User)
        case loading
    }
    
    // MARK: - Computed Properties
    var isAuthenticated: Bool {
        switch authState {
        case .authenticated, .guest:
            return true
        case .unauthenticated, .loading:
            return false
        }
    }
    
    var hasSkippedLogin: Bool {
        get { defaults.bool(forKey: hasSkippedLoginKey) }
        set { defaults.set(newValue, forKey: hasSkippedLoginKey) }
    }
    
    var currentUser: User? {
        switch authState {
        case .authenticated(let user), .guest(let user):
            return user
        case .unauthenticated, .loading:
            return nil
        }
    }
    
    func isUsernameAvailable(_ username: String) async throws -> Bool {
            let snapshot = try await db.collection("users")
                .whereField("username", isEqualTo: username.lowercased())
                .getDocuments()
            
            return snapshot.documents.isEmpty
        }
    
    // MARK: - Initialization
    init() {
        checkAuthenticationStatus()
    }
    
    // MARK: - Authentication Methods
    func checkAuthenticationStatus() {
        isLoading = true
        
        if let currentUser = auth.currentUser {
            Task {
                await fetchUserData(userId: currentUser.uid)
            }
        } else if hasSkippedLogin {
            setupGuestUser()
        } else {
            authState = .unauthenticated
            isLoading = false
        }
    }
    
    func skipAuthentication() {
        hasSkippedLogin = true
        setupGuestUser()
    }
    
    // НОВЫЙ МЕТОД ДЛЯ GOOGLE SIGN-IN ← ДОБАВЛЯЕМ
    func signInWithGoogle(idToken: String, accessToken: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Создаем учетные данные Firebase из токенов Google
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: accessToken
        )
        
        // Входим в Firebase
        let authResult = try await auth.signIn(with: credential)
        hasSkippedLogin = false
        
        // Получаем данные пользователя
        await fetchUserData(userId: authResult.user.uid)
    }
    
    func signUp(email: String, password: String, username: String, fullName: String? = nil) async throws {
        isLoading = true
        defer { isLoading = false }
            
        // 1. Проверяем уникальность username
        guard try await isUsernameAvailable(username) else {
            throw NSError(
                domain: "AuthService",
                code: 409,
                userInfo: [NSLocalizedDescriptionKey: "Имя пользователя '\(username)' уже занято"]
            )
        }
            
        // 2. Создаем пользователя в Firebase Auth
        let authResult = try await auth.createUser(withEmail: email, password: password)
            
        // 3. Создаем объект User
        let newUser = User(
            id: authResult.user.uid,
            email: email,
            username: username.lowercased(), // Сохраняем в нижнемрегистре
            fullName: fullName
        )
        
        // 4. Сохраняем в Firestore
        try await saveUserToFirestore(user: newUser)
        authState = .authenticated(newUser)
        hasSkippedLogin = false
    }
    
    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await auth.signIn(withEmail: email, password: password)
        hasSkippedLogin = false
        
        if let currentUser = auth.currentUser {
            await fetchUserData(userId: currentUser.uid)
        }
    }
    
    func signOut() throws {
        try auth.signOut()
        hasSkippedLogin = false
        authState = .unauthenticated
    }
    
    // MARK: - Private Methods
    private func setupGuestUser() {
        let guestUser = User(
            id: "guest_\(UUID().uuidString)",
            email: "guest@example.com",
            username: "Гость"
        )
        authState = .guest(guestUser)
        isLoading = false
    }
    
    private func saveUserToFirestore(user: User) async throws {
        let userData: [String: Any] = [
            "id": user.id,
            "email": user.email,
            "username": user.username, // ✅ Теперь обязательное поле
            "fullName": user.fullName ?? "",
            "profileImageUrl": user.profileImageUrl ?? "",
            "createdAt": Timestamp(date: user.createdAt)
        ]
            
        try await db.collection("users").document(user.id).setData(userData)
    }
    
    private func fetchUserData(userId: String) async {
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            
            if let data = document.data(), document.exists {
                // ✅ ОБЯЗАТЕЛЬНО распаковываем username
                guard let username = data["username"] as? String else {
                    // Если username нет в данных, используем email или дефолтное значение
                    let email = data["email"] as? String ?? ""
                    let fallbackUsername = email.components(separatedBy: "@").first ?? "user_\(userId.prefix(6))"
                    
                    let user = User(
                        id: userId,
                        email: email,
                        username: fallbackUsername, // ✅ Обязательное поле
                        fullName: data["fullName"] as? String,
                        profileImageUrl: data["profileImageUrl"] as? String,
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    )
                    
                    authState = .authenticated(user)
                    return
                }
                
                // ✅ Все поля есть - создаем пользователя
                let user = User(
                    id: userId,
                    email: data["email"] as? String ?? "",
                    username: username, // ✅ Теперь не опциональное
                    fullName: data["fullName"] as? String,
                    profileImageUrl: data["profileImageUrl"] as? String,
                    createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                )
                
                authState = .authenticated(user)
            } else {
                // Если данные пользователя не найдены, создаем базовую запись
                if let firebaseUser = auth.currentUser {
                    // ✅ Создаем username из email или displayName
                    let email = firebaseUser.email ?? ""
                    let username = firebaseUser.displayName ??
                        email.components(separatedBy: "@").first ??
                        "user_\(userId.prefix(6))"
                    
                    let newUser = User(
                        id: userId,
                        email: email,
                        username: username.lowercased(), // ✅ Обязательное поле
                        fullName: firebaseUser.displayName
                    )
                    
                    try? await saveUserToFirestore(user: newUser)
                    authState = .authenticated(newUser)
                }
            }
        } catch {
            print("Error fetching user data: \(error)")
            // В случае ошибки создаем временного пользователя
            if let firebaseUser = auth.currentUser {
                let email = firebaseUser.email ?? ""
                let username = firebaseUser.displayName ??
                    email.components(separatedBy: "@").first ??
                    "user_\(userId.prefix(6))"
                
                let user = User(
                    id: userId,
                    email: email,
                    username: username.lowercased(), // ✅ Обязательное поле
                    fullName: firebaseUser.displayName
                )
                authState = .authenticated(user)
            }
        }
        
        isLoading = false
    }
}

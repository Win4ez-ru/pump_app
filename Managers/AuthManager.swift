import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

extension AuthManager.AuthState: Equatable {
    static func == (lhs: AuthManager.AuthState, rhs: AuthManager.AuthState) -> Bool {
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
class AuthManager: ObservableObject {
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
    
    func signUp(email: String, password: String, username: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let authResult = try await auth.createUser(withEmail: email, password: password)
        
        let newUser = User(
            id: authResult.user.uid,
            email: email,
            username: username
        )
        
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
            "username": user.username ?? "",
            "createdAt": Timestamp(date: user.createdAt)
        ]
        
        try await db.collection("users").document(user.id).setData(userData)
    }
    
    private func fetchUserData(userId: String) async {
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            
            if let data = document.data(), document.exists {
                let username = data["username"] as? String
                let email = data["email"] as? String ?? ""
                let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                
                let user = User(
                    id: userId,
                    email: email,
                    username: username,
                    createdAt: createdAt
                )
                
                authState = .authenticated(user)
            } else {
                // Если данные пользователя не найдены, создаем базовую запись
                if let firebaseUser = auth.currentUser {
                    let newUser = User(
                        id: userId,
                        email: firebaseUser.email ?? "",
                        username: firebaseUser.displayName
                    )
                    try? await saveUserToFirestore(user: newUser)
                    authState = .authenticated(newUser)
                }
            }
        } catch {
            print("Error fetching user data: \(error)")
            // В случае ошибки все равно считаем пользователя аутентифицированным
            if let firebaseUser = auth.currentUser {
                let user = User(
                    id: userId,
                    email: firebaseUser.email ?? "",
                    username: firebaseUser.displayName
                )
                authState = .authenticated(user)
            }
        }
        
        isLoading = false
    }
}

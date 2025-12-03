// Features/Profile/ProfileViewModel.swift
import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthService) {
        self.authService = authService
        setupBindings()
    }
    
    private func setupBindings() {
        // Следим за изменением authState вместо currentUser
        authService.$authState
            .receive(on: RunLoop.main)
            .sink { [weak self] authState in
                switch authState {
                case .authenticated(let user), .guest(let user):
                    self?.user = user
                case .unauthenticated, .loading:
                    self?.user = nil
                }
            }
            .store(in: &cancellables)
    }
    
    func updateProfile(displayName: String, photoURL: String?) {
        isLoading = true
        errorMessage = nil
        
        // Здесь будет логика обновления профиля
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.isLoading = false
        }
    }
    
    func logout() {
        try? authService.signOut()
    }
}

import Foundation
import Combine

// Вариант 1: Сделать весь класс @MainActor
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var fitnessProfile: ClientFitnessProfile = .demo
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    private let fitnessProfileKey = "client_fitness_profile"
    
    init(authService: AuthService) {
        self.authService = authService
        loadFitnessProfile()
        setupBindings()
    }
    
    private func setupBindings() {
        // Теперь весь код автоматически выполняется на главном акторе
        authService.$authState
            .receive(on: RunLoop.main)
            .sink { [weak self] authState in
                guard let self = self else { return }
                switch authState {
                case .authenticated(let user), .guest(let user):
                    self.user = user
                case .unauthenticated, .loading:
                    self.user = nil
                }
            }
            .store(in: &cancellables)
    }
    
    func updateProfile(displayName: String, photoURL: String?) {
        isLoading = true
        errorMessage = nil

        // Имитация обновления профиля
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.isLoading = false
        }
    }

    func updateFitnessProfile(_ profile: ClientFitnessProfile) {
        fitnessProfile = profile
        saveFitnessProfile()
    }

    func loadFitnessProfile() {
        guard let data = UserDefaults.standard.data(forKey: fitnessProfileKey),
              let profile = try? JSONDecoder().decode(ClientFitnessProfile.self, from: data) else {
            return
        }

        fitnessProfile = profile
    }

    private func saveFitnessProfile() {
        guard let data = try? JSONEncoder().encode(fitnessProfile) else {
            return
        }

        UserDefaults.standard.set(data, forKey: fitnessProfileKey)
    }

    func logout() {
        // Можно вызывать напрямую, так как мы на @MainActor
        try? authService.signOut()
    }
}

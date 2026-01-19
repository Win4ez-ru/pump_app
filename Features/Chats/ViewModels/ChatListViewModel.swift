import SwiftUI
import Combine
import FirebaseAuth
import Foundation

@MainActor
class ChatsListViewModel: ObservableObject {
    @Published var chatRooms: [ChatRoom] = []
    @Published var showNewChatSheet = false
    @Published var errorMessage = ""
    
    private let chatService = ChatService()
    
    // Получаем email текущего пользователя
    var currentUserEmail: String {
        Auth.auth().currentUser?.email ?? ""
    }
    
    func searchUsers(query: String) async -> [User] {
            do {
                return try await chatService.searchUsers(query: query)
            } catch {
                errorMessage = "Ошибка поиска: \(error.localizedDescription)"
                return []
            }
        }
        
        // ✅ НОВЫЙ МЕТОД: Создание чата с пользователем
        func createChat(with user: User) async {
            guard let currentUserId = Auth.auth().currentUser?.uid else {
                errorMessage = "Вы не авторизованы"
                return
            }
            
            guard user.id != currentUserId else {
                errorMessage = "Нельзя писать самому себе"
                return
            }
            
            do {
                let _ = try await chatService.createOrGetChatRoom(
                    with: user,
                    currentUserId: currentUserId
                )
                showNewChatSheet = false
                errorMessage = ""
            } catch {
                errorMessage = "Ошибка создания чата: \(error.localizedDescription)"
            }
        }
    
    // ✅ ВАЖНО: Получаем ID текущего пользователя
    var currentUserId: String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    init() {
        listenToChatRooms()
    }
    
    func listenToChatRooms() {
        // Слушаем чаты по email (или можно переделать на ID)
        chatService.listenToChatRooms(for: currentUserEmail)
        
        chatService.$chatRooms
            .assign(to: &$chatRooms)
    }
    
    deinit {
        chatService.removeListeners()
    }
}

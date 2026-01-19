import SwiftUI
import Combine
import FirebaseAuth

@MainActor
class ChatDetailViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var messageText = ""
    @Published var isLoading = false
    
    private let chatService = ChatService()
    private let chatRoomId: String
    private let otherUserEmail: String
    
    var currentUserEmail: String {
        Auth.auth().currentUser?.email ?? ""
    }
    
    var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }
    
    init(chatRoomId: String, otherUserEmail: String) {
        self.chatRoomId = chatRoomId
        self.otherUserEmail = otherUserEmail
        
        chatService.listenToMessages(chatRoomId: chatRoomId)
        chatService.$messages
            .assign(to: &$messages)
    }
    
    func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        isLoading = true
        
        Task {
            do {
                try await chatService.sendMessage(
                    messageText,
                    chatRoomId: chatRoomId,
                    senderId: currentUserId,
                    senderEmail: currentUserEmail
                )
                messageText = ""
            } catch {
                print("Ошибка отправки: \(error)")
            }
            isLoading = false
        }
    }
    
    deinit {
        chatService.removeListeners()
    }
}

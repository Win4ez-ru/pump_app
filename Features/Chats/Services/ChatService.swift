import Firebase
import FirebaseFirestore
import Combine

class ChatService: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var chatRooms: [ChatRoom] = []
    
    private let db = Firestore.firestore()
    private var messagesListener: ListenerRegistration?
    private var chatRoomsListener: ListenerRegistration?
    
    // MARK: - Chat Rooms
    
    func searchUsers(query: String) async throws -> [User] {
        guard !query.isEmpty else { return [] }
        
        let searchQuery = query.lowercased()
        
        // Создаем отдельные запросы для каждого поля
        let usernameQuery = db.collection("users")
            .whereField("username", isGreaterThanOrEqualTo: searchQuery)
            .whereField("username", isLessThan: searchQuery + "z")
            .limit(to: 10)
        
        let emailQuery = db.collection("users")
            .whereField("email", isEqualTo: searchQuery)
            .limit(to: 10)
        
        let fullNameQuery = db.collection("users")
            .whereField("fullName", isGreaterThanOrEqualTo: searchQuery)
            .whereField("fullName", isLessThan: searchQuery + "z")
            .limit(to: 10)
        
        // Выполняем все запросы параллельно
        async let usernameResults = usernameQuery.getDocuments()
        async let emailResults = emailQuery.getDocuments()
        async let fullNameResults = fullNameQuery.getDocuments()
        
        // Ждем завершения всех запросов
        let (usernameSnapshot, emailSnapshot, fullNameSnapshot) =
            try await (usernameResults, emailResults, fullNameResults)
        
        // Объединяем результаты
        var allUsers: [User] = []
        var userIds = Set<String>()
        
        // Обрабатываем результаты поиска по username
        for document in usernameSnapshot.documents {
            if let user = try? document.data(as: User.self),
               !userIds.contains(user.id) {
                allUsers.append(user)
                userIds.insert(user.id)
            }
        }
        
        // Обрабатываем результаты поиска по email
        for document in emailSnapshot.documents {
            if let user = try? document.data(as: User.self),
               !userIds.contains(user.id) {
                allUsers.append(user)
                userIds.insert(user.id)
            }
        }
        
        // Обрабатываем результаты поиска по fullName
        for document in fullNameSnapshot.documents {
            if let user = try? document.data(as: User.self),
               !userIds.contains(user.id) {
                allUsers.append(user)
                userIds.insert(user.id)
            }
        }
        
        // Сортируем по релевантности (сначала точные совпадения)
        return allUsers.sorted { user1, user2 in
            let score1 = relevanceScore(for: user1, query: searchQuery)
            let score2 = relevanceScore(for: user2, query: searchQuery)
            return score1 > score2
        }
    }

    // Вспомогательная функция для оценки релевантности
    private func relevanceScore(for user: User, query: String) -> Int {
        var score = 0
        
        // Точное совпадение username получает наивысший балл
        if user.username.lowercased() == query {
            score += 100
        } else if user.username.lowercased().hasPrefix(query) {
            score += 50
        } else if user.username.lowercased().contains(query) {
            score += 20
        }
        
        // Точное совпадение email
        if user.email.lowercased() == query {
            score += 80
        }
        
        // Совпадение по fullName
        if let fullName = user.fullName?.lowercased() {
            if fullName == query {
                score += 60
            } else if fullName.hasPrefix(query) {
                score += 30
            } else if fullName.contains(query) {
                score += 10
            }
        }
        
        return score
    }
    
    func createOrGetChatRoom(with user: User, currentUserId: String) async throws -> String {
        let participants = [currentUserId, user.id].sorted()
        let chatRoomId = participants.joined(separator: "_")
        
        let docRef = db.collection("chatRooms").document(chatRoomId)
        let snapshot = try await docRef.getDocument()
        
        if !snapshot.exists {
            try await docRef.setData([
                "participants": participants,
                "participantEmails": [user.email],
                "participantNames": [user.displayName],
                "createdAt": FieldValue.serverTimestamp(),
                "lastMessage": "",
                "lastMessageTimestamp": FieldValue.serverTimestamp()
            ])
        }
        
        return chatRoomId
    }
    
    func listenToChatRooms(for userEmail: String) {
        chatRoomsListener?.remove()
        
        chatRoomsListener = db.collection("chatRooms")
            .whereField("participants", arrayContains: userEmail)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let rooms = documents.compactMap { ChatRoom(document: $0) }
                DispatchQueue.main.async {
                    self?.chatRooms = rooms
                }
            }
    }
    
    // MARK: - Messages
    
    func listenToMessages(chatRoomId: String) {
        messagesListener?.remove()
        
        messagesListener = db.collection("chatRooms")
            .document(chatRoomId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .limit(to: 100)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let msgs = documents.compactMap { ChatMessage(document: $0) }
                DispatchQueue.main.async {
                    self?.messages = msgs
                }
            }
    }
    
    func sendMessage(_ content: String, chatRoomId: String, senderId: String, senderEmail: String) async throws {
        try await db.collection("chatRooms")
            .document(chatRoomId)
            .collection("messages")
            .addDocument(data: [
                "content": content,
                "senderId": senderId,
                "senderEmail": senderEmail,
                "timestamp": FieldValue.serverTimestamp()
            ])
        
        try await db.collection("chatRooms").document(chatRoomId).updateData([
            "lastMessage": content
        ])
    }
    
    func removeListeners() {
        messagesListener?.remove()
        chatRoomsListener?.remove()
    }
}

import FirebaseFirestore

struct ChatMessage: Identifiable, Equatable {
    @DocumentID var id: String?
    let content: String
    let senderId: String
    let senderEmail: String
    let timestamp: Date
    
    init(content: String, senderId: String, senderEmail: String) {
        self.content = content
        self.senderId = senderId
        self.senderEmail = senderEmail
        self.timestamp = Date()
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let content = data["content"] as? String,
              let senderId = data["senderId"] as? String,
              let senderEmail = data["senderEmail"] as? String,
              let timestamp = (data["timestamp"] as? Timestamp)?.dateValue()
        else { return nil }
        
        self.id = document.documentID
        self.content = content
        self.senderId = senderId
        self.senderEmail = senderEmail
        self.timestamp = timestamp
    }
}

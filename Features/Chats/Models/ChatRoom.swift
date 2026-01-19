import FirebaseFirestore

struct ChatRoom: Identifiable {
    @DocumentID var id: String?
    let participants: [String]
    let createdAt: Date
    let lastMessage: String?
    
    init(participants: [String]) {
        self.participants = participants.sorted()
        self.createdAt = Date()
        self.lastMessage = nil
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let participants = data["participants"] as? [String],
              let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
        else { return nil }
        
        self.id = document.documentID
        self.participants = participants
        self.createdAt = createdAt
        self.lastMessage = data["lastMessage"] as? String
    }
}

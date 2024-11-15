import FirebaseFirestore

struct Contact {
    let id: String
    let name: String
    let email: String
    let lastMessage: String?
    let lastMessageDate: Date?
}

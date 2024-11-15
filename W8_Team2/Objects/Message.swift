import Foundation
import FirebaseFirestore

struct Message {
    let senderId: String
    let text: String
    let timestamp: Date
    
    init(senderId: String, text: String, timestamp: Date) {
        self.senderId = senderId
        self.text = text
        self.timestamp = timestamp
    }
    
    init?(data: [String: Any]) {
        guard let senderId = data["senderId"] as? String,
              let text = data["text"] as? String,
              let timestamp = data["timestamp"] as? Timestamp else {
            return nil
        }
        
        self.senderId = senderId
        self.text = text
        self.timestamp = timestamp.dateValue()
    }
}

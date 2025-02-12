import Foundation

struct Message: Identifiable, Codable {
    var id: UUID
    var text: String
    var isFromUser: Bool
    var timestamp: Date
    
    init(text: String, isFromUser: Bool) {
        self.id = UUID()
        self.text = text
        self.isFromUser = isFromUser
        self.timestamp = Date()
    }
}

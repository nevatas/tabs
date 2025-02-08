import Foundation

struct Message: Identifiable, Codable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp = Date()
}

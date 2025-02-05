import Foundation

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp = Date()
}

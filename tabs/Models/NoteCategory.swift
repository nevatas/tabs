import Foundation

enum NoteCategory: String, CaseIterable, Identifiable {
    case inbox = "Inbox"
    case words = "Words"
    case ideas = "Ideas"
    case trip = "Trip"
    var id: Self { self }
}

struct Note: Identifiable {
    let id = UUID()
    let text: String
    let category: NoteCategory
    let timestamp = Date()
}

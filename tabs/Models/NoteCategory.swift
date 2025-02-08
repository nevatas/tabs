import Foundation

enum NoteCategory: String, CaseIterable, Identifiable, Codable {
    case inbox = "Inbox"
    case words = "Words"
    case ideas = "Ideas"
    case trip = "Trip"
    
    var id: Self { self }
    
    var index: Int {
            NoteCategory.allCases.firstIndex(of: self) ?? 0
        }
    
    var emoji: String {
        switch self {
        case .inbox: return "📥"
        case .words: return "📝"
        case .ideas: return "💡"
        case .trip: return "✈️"
        }
    }
}

struct Note: Identifiable, Codable {
    let id = UUID()
    let text: String
    let category: NoteCategory
    let timestamp = Date()
}

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
    var id: UUID
    var text: String
    var category: NoteCategory
    var timestamp: Date
    
    init(text: String, category: NoteCategory) {
        self.id = UUID()
        self.text = text
        self.category = category
        self.timestamp = Date()
    }
}

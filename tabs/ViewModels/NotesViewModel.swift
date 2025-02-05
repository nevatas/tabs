// 2. ViewModel

import Foundation
import SwiftUI

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var newNoteText = ""
    @Published var selectedCategory: NoteCategory = .inbox
    
    func addNote() {
        guard !newNoteText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let newNote = Note(text: newNoteText, category: selectedCategory)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            notes.append(newNote) // Добавляем в конец массива
        }
        
        newNoteText = ""
    }
    
    func filteredNotes(for category: NoteCategory) -> [Note] {
        notes.filter { $0.category == category } // Убрана сортировка по времени
    }
    
    func deleteNote(withID id: UUID) {
        withAnimation(.easeOut(duration: 0.2)) { notes.removeAll { $0.id == id } }
    }
}

// NotesViewModel.swift
import Foundation
import SwiftUI

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var newNoteText = ""
    @Published var selectedCategory: NoteCategory = .inbox
    
    init() {
        loadNotes()
    }
    
    private func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: "savedNotes") {
            if let decodedNotes = try? JSONDecoder().decode([Note].self, from: data) {
                self.notes = decodedNotes
            }
        }
    }
    
    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: "savedNotes")
        }
    }
    
    func addNote() {
        guard !newNoteText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let newNote = Note(text: newNoteText, category: selectedCategory)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            notes.append(newNote)
            saveNotes()
        }
        
        newNoteText = ""
    }
    
    func filteredNotes(for category: NoteCategory) -> [Note] {
        notes.filter { $0.category == category }
    }
    
    func deleteNote(withID id: UUID) {
        withAnimation(.easeOut(duration: 0.2)) {
            notes.removeAll { $0.id == id }
            saveNotes()
        }
    }
    
    func moveNote(withID id: UUID, to category: NoteCategory) {
        guard let index = notes.firstIndex(where: { $0.id == id }) else { return }
        let movedNote = Note(text: notes[index].text, category: category)
        
        withAnimation {
            notes[index] = movedNote
            saveNotes()
        }
    }
}

// ChatViewModel.swift
import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var newMessageText = ""
    
    func sendMessage() {
        guard !newMessageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let newMessage = Message(text: newMessageText, isFromUser: true)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            messages.append(newMessage)
        }
        
        newMessageText = ""
    }
}

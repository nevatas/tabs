// InputBarView.swift
import SwiftUI

struct InputBarView: View {
    @EnvironmentObject var viewModel: NotesViewModel
    @FocusState var isTextFieldFocused: Bool // Убираем private
    @State private var isPlusButtonActive = true
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                TextField("", text: $viewModel.newNoteText, axis: .vertical)
                    .lineLimit(1...5)
                    .placeholder(when: viewModel.newNoteText.isEmpty) {
                        Text("Новая заметка")
                            .foregroundColor(Color("SecondaryText"))
                    }
                    .focused($isTextFieldFocused)
                    .submitLabel(.send)
                    .onSubmit {
                        viewModel.addNote()
                    }
                    .foregroundColor(Color("PrimaryText"))
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                
                HStack {
                    HStack(spacing: 8) {
                        ButtonPlusView(isActive: $isPlusButtonActive)
                    }
                    
                    Spacer()
                    
                    ButtonSendView(
                        isEmpty: viewModel.newNoteText.trimmingCharacters(in: .whitespaces).isEmpty,
                        action: {
                            viewModel.addNote()
                        }
                    )
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color("SecondaryBackground"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color("TeritaryBackground"), lineWidth: 1)
                    )
            )
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color("PrimaryBackground"))
    }
}

// Extension для placeholder в TextField
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct ButtonPlusView: View {
    @Binding var isActive: Bool
    
    var body: some View {
        Menu {
            Button(action: {
                // Действие для прикрепления фото
            }) {
                Label("Прикрепить Фото", systemImage: "photo")
            }
            
            Button(action: {
                // Действие для создания снимка
            }) {
                Label("Сделать Снимок", systemImage: "camera")
            }
            
            Button(action: {
                // Действие для прикрепления файлов
            }) {
                Label("Прикрепить Файлы", systemImage: "folder")
            }
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 20))
                .foregroundColor(isActive ? Color("PrimaryText") : Color("SecondaryText"))
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isActive ? Color("TeritaryBackground") : Color.clear)
                )
                .shadow(
                    color: Color.black.opacity(0.16),
                    radius: 2,
                    x: 0,
                    y: 1
                )
        }
    }
}

struct ButtonSendView: View {
    let isEmpty: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.up")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isEmpty ? Color("AccentText") : Color("AccentText"))
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isEmpty ? Color("SecondaryText") : Color("AccentBackground"))
                )
        }
        .disabled(isEmpty)
    }
}

#Preview {
    InputBarView()
        .environmentObject(NotesViewModel())
}

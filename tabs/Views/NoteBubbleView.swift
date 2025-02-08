import SwiftUI

struct NoteBubbleView: View {
    let note: Note
    @EnvironmentObject var viewModel: NotesViewModel
    @State private var opacity: Double = 0
    
    var body: some View {
        HStack {
            Text(note.text)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color("SecondaryBackground"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(RoundedRectangle(cornerRadius: 12))
                .opacity(opacity)
                .contextMenu {
                    Button(role: .destructive) {
                        viewModel.deleteNote(withID: note.id)
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                    
                    Menu("Переместить в...") {
                        ForEach(NoteCategory.allCases.filter { $0 != note.category }) { category in
                            Button(category.rawValue) {
                                viewModel.moveNote(withID: note.id, to: category)
                            }
                        }
                    }
                }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.2)) {
                opacity = 1
            }
        }
    }
}

import SwiftUI

struct TabsView: View {
    @Binding var activeTabIndex: Int
    @Binding var previousTabIndex: Int
    @EnvironmentObject var viewModel: NotesViewModel
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(NoteCategory.allCases) { category in
                        TabItemView(
                            title: category.rawValue,
                            emoji: category.emoji,
                            isActive: viewModel.selectedCategory == category,
                            action: {
                                handleTabSelection(category: category)
                            }
                        )
                        .id(category)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .onChange(of: viewModel.selectedCategory) { _, newCategory in
                withAnimation {
                    scrollProxy.scrollTo(newCategory, anchor: .center)
                }
            }
        }
        .background(Color("PrimaryBackground"))
    }
    
    private func handleTabSelection(category: NoteCategory) {
        previousTabIndex = activeTabIndex
        let newIndex = NoteCategory.allCases.firstIndex(of: category) ?? 0
        
        if abs(newIndex - activeTabIndex) == 1 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                activeTabIndex = newIndex
                viewModel.selectedCategory = category
            }
        } else {
            withAnimation(.none) {
                activeTabIndex = newIndex
            }
            viewModel.selectedCategory = category
        }
    }
}

struct TabItemView: View {
    let title: String
    let emoji: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(emoji)
                    .opacity(isActive ? 1 : 0.5)
                Text(title)
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(isActive ? .primary : .secondary)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                isActive ? Color("SecondaryBackground") : Color("PrimaryBackground")
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isActive ? Color("TeritaryBackground") : Color("DividedColor"),
                        lineWidth: 1
                    )
            )
        }
    }
}

#Preview {
    TabsView(
        activeTabIndex: .constant(0),
        previousTabIndex: .constant(0)
    )
    .environmentObject(NotesViewModel())
}

// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var activeTabIndex: Int = 0
    @State private var previousTabIndex: Int = 0
    @FocusState private var isInputBarFocused: Bool
    
    var body: some View {
            VStack(spacing: 0) {
                TabsView(
                    activeTabIndex: $activeTabIndex,
                    previousTabIndex: $previousTabIndex
                )
                contentView
                InputBarView(isTextFieldFocused: _isInputBarFocused) // Передаем FocusState
            }
            .onChange(of: viewModel.selectedCategory) { _, newValue in
                activeTabIndex = newValue.index
            }
            .environmentObject(viewModel)
            .background(Color("PrimaryBackground"))
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        if !viewModel.newNoteText.isEmpty {
                            return // Не скрываем клавиатуру, если поле не пустое
                        }
                        isInputBarFocused = false
                    }
            )
        }
    
    private var contentView: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(NoteCategory.allCases) { category in
                    NoteListView(category: category)
                        .environmentObject(viewModel)
                        .frame(width: geometry.size.width)
                }
            }
            .offset(x: -CGFloat(activeTabIndex) * geometry.size.width)
            .animation(
                abs(activeTabIndex - previousTabIndex) == 1
                ? .interactiveSpring(response: 0.35, dampingFraction: 0.8)
                : .none,
                value: activeTabIndex
            )
            .gesture(
                DragGesture()
                    .onEnded { value in
                        hideKeyboard()
                        previousTabIndex = activeTabIndex
                        let translation = value.translation.width
                        let velocity = value.velocity.width
                        
                        let direction: Int
                        if abs(translation) > geometry.size.width * 0.2 || abs(velocity) > 800 {
                            direction = translation < 0 ? 1 : -1
                        } else {
                            direction = 0
                        }
                        
                        let newIndex = max(0, min(activeTabIndex + direction, NoteCategory.allCases.count - 1))
                        
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            activeTabIndex = newIndex
                            viewModel.selectedCategory = NoteCategory.allCases[newIndex]
                        }
                    }
            )
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct NoteListView: View {
    let category: NoteCategory
    @EnvironmentObject var viewModel: NotesViewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.filteredNotes(for: category)) { note in
                        NoteBubbleView(note: note)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity))
                            )
                            .id(note.id)
                    }
                    
                    GeometryReader { geometry in
                        Color.clear
                            .preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geometry.frame(in: .named("scroll")).maxY
                            )
                    }
                    .frame(height: 1)
                    
                    Color.clear
                        .frame(height: 16)
                        .id("bottomAnchor")
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .coordinateSpace(name: "scroll")
            .onChange(of: viewModel.notes.count) { _, _ in
                let proxyRef = proxy
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        proxyRef.scrollTo("bottomAnchor", anchor: .bottom)
                    }
                }
            }
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { maxY in
                let proxyRef = proxy
                if maxY > UIScreen.main.bounds.height * 0.7 {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        proxyRef.scrollTo("bottomAnchor", anchor: .bottom)
                    }
                }
            }
        }
    }
}

// Остальные структуры остаются без изменений

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    ContentView()
}

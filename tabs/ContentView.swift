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
            InputBarView()
        }
        .onChange(of: viewModel.selectedCategory) { _ in
            activeTabIndex = viewModel.selectedCategory.index
        }
        .environmentObject(viewModel)
        .background(Color("PrimaryBackground"))
        .onTapGesture {
            isInputBarFocused = false
        }
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
                        isInputBarFocused = false
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
                    
                    // Вспомогательный спейсер для определения необходимости скролла
                    GeometryReader { geometry in
                        Color.clear
                            .preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geometry.frame(in: .named("scroll")).maxY
                            )
                    }
                    .frame(height: 1)
                    
                    // Нижний отступ для корректного отображения последней заметки
                    Color.clear
                        .frame(height: 16)
                        .id("bottomAnchor")
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .coordinateSpace(name: "scroll")
            .onChange(of: viewModel.notes.count) { [oldCount = viewModel.notes.count] newCount in
                // Проверяем, добавлена ли новая заметка
                if newCount > oldCount {
                    // Используем небольшую задержку, чтобы анимация вставки заметки успела начаться
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            proxy.scrollTo("bottomAnchor", anchor: .bottom)
                        }
                    }
                }
            }
            // Отслеживаем необходимость скролла
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { maxY in
                // Если контент не помещается, скроллим
                if maxY > UIScreen.main.bounds.height * 0.7 {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        proxy.scrollTo("bottomAnchor", anchor: .bottom)
                    }
                }
            }
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    ContentView()
}

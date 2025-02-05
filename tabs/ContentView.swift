//
//  ContentView.swift
//  tabs
//
//  Created by Сергей Токарев on 05.02.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var activeTabIndex: Int = 0
    @State private var previousTabIndex: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            categoryTabs
            contentView
            inputBar
        }
        .onChange(of: viewModel.selectedCategory) { newCategory in
            activeTabIndex = newCategory.index
        }
    }
    
    // Вкладки категорий
    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(NoteCategory.allCases) { category in
                    Button(action: {
                        previousTabIndex = activeTabIndex
                        let newIndex = category.index
                        
                        if abs(newIndex - activeTabIndex) == 1 {
                            // Соседние вкладки - анимация перелистывания
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                activeTabIndex = newIndex
                                viewModel.selectedCategory = category
                            }
                        } else {
                            // Не соседние - мгновенное переключение
                            withAnimation(.none) {
                                activeTabIndex = newIndex
                            }
                            viewModel.selectedCategory = category
                        }
                    }) {
                        Text(category.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(viewModel.selectedCategory == category ? .primary : .secondary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                viewModel.selectedCategory == category
                                ? Color.gray.opacity(0.2)
                                : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(.ultraThinMaterial)
    }
    
    // Контент с поддержкой свайпа
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
    
    // Панель ввода
    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Новая заметка...", text: $viewModel.newNoteText)
                .textFieldStyle(.roundedBorder)
                .onSubmit(viewModel.addNote)
            
            Button(action: viewModel.addNote) {
                Image(systemName: "plus.circle.fill")
                    .padding(10)
                    .background(viewModel.newNoteText.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .disabled(viewModel.newNoteText.isEmpty)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

// MARK: - Компоненты
struct NoteListView: View {
    let category: NoteCategory
    @EnvironmentObject var viewModel: NotesViewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.filteredNotes(for: category)) { note in
                        NoteBubble(note: note)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity))
                            )
                            .id(note.id)
                    }
                    
                    Color.clear
                        .frame(height: 0)
                        .id("bottomAnchor")
                }
                .padding(.horizontal)
                .padding(.top)
                .onAppear {
                    proxy.scrollTo("bottomAnchor", anchor: .bottom)
                }
            }
            .onChange(of: viewModel.notes.count) { _ in
                withAnimation {
                    proxy.scrollTo("bottomAnchor", anchor: .bottom)
                }
            }
        }
    }
}

struct NoteBubble: View {
    let note: Note
    @EnvironmentObject var viewModel: NotesViewModel
    
    var body: some View {
        HStack {
            Text(note.text)
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contextMenu {
                    Button(role: .destructive) {
                        viewModel.deleteNote(withID: note.id)
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                    
                    Button("Переместить") { /* ... */ }
                }
            
            Spacer()
        }
    }
}

// MARK: - Расширения
extension NoteCategory {
    var index: Int {
        NoteCategory.allCases.firstIndex(of: self) ?? 0
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}

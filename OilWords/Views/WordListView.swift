import SwiftUI

struct WordListView: View {
    @EnvironmentObject var store: WordStore
    @State private var searchText = ""
    @State private var selectedCategory: String = "All"
    @State private var showAddWord = false
    @State private var showFlashcards = false
    @State private var showQuiz = false
    @State private var editingWord: Word? = nil

    var filteredWords: [Word] {
        store.words.filter { word in
            let matchesSearch = searchText.isEmpty ||
                word.term.localizedCaseInsensitiveContains(searchText) ||
                word.definition.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == "All" || word.category == selectedCategory
            return matchesSearch && matchesCategory
        }
    }

    var allCategories: [String] {
        ["All"] + store.categories
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress banner
                progressBanner

                // Category filter
                categoryScroll

                // Word list
                List {
                    ForEach(filteredWords) { word in
                        WordRowView(word: word)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingWord = word
                            }
                    }
                    .onDelete { offsets in
                        let indices = offsets.compactMap { i in
                            store.words.firstIndex(where: { $0.id == filteredWords[i].id })
                        }
                        store.delete(at: IndexSet(indices))
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("OilWords")
            .searchable(text: $searchText, prompt: "Search words…")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button { showFlashcards = true } label: {
                            Label("Flashcards", systemImage: "rectangle.on.rectangle")
                        }
                        Button { showQuiz = true } label: {
                            Label("Quiz", systemImage: "questionmark.circle")
                        }
                    } label: {
                        Image(systemName: "graduationcap")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAddWord = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddWord) {
                AddWordView()
                    .environmentObject(store)
            }
            .sheet(item: $editingWord) { word in
                AddWordView(editingWord: word)
                    .environmentObject(store)
            }
            .sheet(isPresented: $showFlashcards) {
                FlashcardView()
                    .environmentObject(store)
            }
            .sheet(isPresented: $showQuiz) {
                QuizView()
                    .environmentObject(store)
            }
        }
    }

    // MARK: - Subviews

    private var progressBanner: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Progress")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(store.learnedCount) / \(store.words.count) learned")
                    .font(.subheadline.bold())
            }
            Spacer()
            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: store.words.isEmpty ? 0 : CGFloat(store.learnedCount) / CGFloat(store.words.count))
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text(store.words.isEmpty ? "0%" : "\(Int(Double(store.learnedCount) / Double(store.words.count) * 100))%")
                    .font(.caption2.bold())
            }
            .frame(width: 44, height: 44)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }

    private var categoryScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(allCategories, id: \.self) { cat in
                    Button {
                        selectedCategory = cat
                    } label: {
                        Text(cat)
                            .font(.subheadline)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(selectedCategory == cat ? Color.accentColor : Color(.secondarySystemFill))
                            .foregroundColor(selectedCategory == cat ? .white : .primary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Word Row

struct WordRowView: View {
    @EnvironmentObject var store: WordStore
    let word: Word

    var body: some View {
        HStack(spacing: 12) {
            Button {
                store.toggleLearned(word)
            } label: {
                Image(systemName: word.isLearned ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(word.isLearned ? .green : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                Text(word.term)
                    .font(.headline)
                    .strikethrough(word.isLearned, color: .secondary)
                Text(word.definition)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Text(word.category)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.secondarySystemFill))
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
}

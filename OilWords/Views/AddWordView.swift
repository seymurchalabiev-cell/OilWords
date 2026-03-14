import SwiftUI

struct AddWordView: View {
    @EnvironmentObject var store: WordStore
    @Environment(\.dismiss) private var dismiss

    var editingWord: Word?

    @State private var term = ""
    @State private var definition = ""
    @State private var category = ""
    @State private var isLearned = false
    @State private var showingCategoryPicker = false

    private var isEditing: Bool { editingWord != nil }

    var body: some View {
        NavigationView {
            Form {
                Section("Word") {
                    TextField("Term (e.g. Crude Oil)", text: $term)
                    TextField("Definition", text: $definition, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Category") {
                    HStack {
                        TextField("Category (e.g. Drilling)", text: $category)
                        Spacer()
                        if !store.categories.isEmpty {
                            Menu {
                                ForEach(store.categories, id: \.self) { cat in
                                    Button(cat) { category = cat }
                                }
                            } label: {
                                Image(systemName: "chevron.down.circle")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }

                if isEditing {
                    Section {
                        Toggle("Learned", isOn: $isLearned)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Word" : "Add Word")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Add") {
                        save()
                        dismiss()
                    }
                    .disabled(term.trimmingCharacters(in: .whitespaces).isEmpty ||
                              definition.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            if let word = editingWord {
                term = word.term
                definition = word.definition
                category = word.category
                isLearned = word.isLearned
            }
        }
    }

    private func save() {
        let trimmedTerm = term.trimmingCharacters(in: .whitespaces)
        let trimmedDef = definition.trimmingCharacters(in: .whitespaces)
        let trimmedCat = category.trimmingCharacters(in: .whitespaces).isEmpty ? "General" : category.trimmingCharacters(in: .whitespaces)

        if let existing = editingWord {
            var updated = existing
            updated.term = trimmedTerm
            updated.definition = trimmedDef
            updated.category = trimmedCat
            updated.isLearned = isLearned
            store.update(updated)
        } else {
            store.add(Word(term: trimmedTerm, definition: trimmedDef, category: trimmedCat))
        }
    }
}

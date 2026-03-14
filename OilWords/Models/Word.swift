import Foundation

/// Represents a vocabulary word with its definition and metadata.
struct Word: Identifiable, Codable, Equatable {
    let id: UUID
    var term: String
    var definition: String
    var category: String
    var isLearned: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        term: String,
        definition: String,
        category: String = "General",
        isLearned: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.term = term
        self.definition = definition
        self.category = category
        self.isLearned = isLearned
        self.createdAt = createdAt
    }
}

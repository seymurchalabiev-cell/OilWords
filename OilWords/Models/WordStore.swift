import Foundation
import Combine

/// Manages the collection of words and persists them to disk.
class WordStore: ObservableObject {
    @Published var words: [Word] = []

    private let saveKey = "oilwords_saved_words"

    // MARK: - Computed helpers

    var categories: [String] {
        let cats = words.map { $0.category }
        return Array(Set(cats)).sorted()
    }

    var learnedCount: Int { words.filter { $0.isLearned }.count }
    var unlearnedCount: Int { words.filter { !$0.isLearned }.count }

    // MARK: - Init

    init() {
        load()
        if words.isEmpty {
            words = Self.sampleWords
            save()
        }
    }

    // MARK: - CRUD

    func add(_ word: Word) {
        words.append(word)
        save()
    }

    func update(_ word: Word) {
        guard let index = words.firstIndex(where: { $0.id == word.id }) else { return }
        words[index] = word
        save()
    }

    func delete(at offsets: IndexSet) {
        words.remove(atOffsets: offsets)
        save()
    }

    func toggleLearned(_ word: Word) {
        guard let index = words.firstIndex(where: { $0.id == word.id }) else { return }
        words[index].isLearned.toggle()
        save()
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(words) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Word].self, from: data) {
            words = decoded
        }
    }

    // MARK: - Sample data (oil industry vocabulary)

    static let sampleWords: [Word] = [
        Word(term: "Crude Oil", definition: "Unrefined petroleum extracted from the ground; a mixture of hydrocarbons.", category: "Basics"),
        Word(term: "Reservoir", definition: "An underground formation of rock that contains oil and/or natural gas.", category: "Basics"),
        Word(term: "Wellbore", definition: "The drilled hole or borehole, including the surrounding rock face.", category: "Drilling"),
        Word(term: "Casing", definition: "Steel pipe cemented in a wellbore to stabilize the well and prevent collapse.", category: "Drilling"),
        Word(term: "Mud Logging", definition: "The process of monitoring drilling fluid (mud) returning from the wellbore for signs of hydrocarbons.", category: "Drilling"),
        Word(term: "BOP (Blowout Preventer)", definition: "Safety valve system installed on top of a well to prevent uncontrolled release of crude oil or gas.", category: "Drilling"),
        Word(term: "Porosity", definition: "The percentage of void space within a rock that can store fluids.", category: "Reservoir"),
        Word(term: "Permeability", definition: "A measure of how easily fluid can flow through porous rock.", category: "Reservoir"),
        Word(term: "Saturation", definition: "The fraction of a rock's pore space occupied by a particular fluid.", category: "Reservoir"),
        Word(term: "Seismic Survey", definition: "A method of mapping subsurface geology using reflected sound waves.", category: "Exploration"),
        Word(term: "Hydrocarbon", definition: "An organic compound consisting of hydrogen and carbon atoms; the main component of petroleum.", category: "Basics"),
        Word(term: "API Gravity", definition: "A measure of how heavy or light petroleum liquid is compared to water, defined by the American Petroleum Institute.", category: "Basics"),
        Word(term: "Upstream", definition: "The sector of the oil industry focused on exploration and production (E&P).", category: "Industry"),
        Word(term: "Midstream", definition: "The sector focused on transportation, storage, and wholesale marketing of crude oil and natural gas.", category: "Industry"),
        Word(term: "Downstream", definition: "The sector focused on refining and selling petroleum products to consumers.", category: "Industry"),
        Word(term: "Enhanced Oil Recovery (EOR)", definition: "Techniques used to increase the amount of oil extracted from a reservoir beyond primary and secondary methods.", category: "Production"),
        Word(term: "Fracking (Hydraulic Fracturing)", definition: "A technique to crack open rock formations by injecting high-pressure fluid to release oil or gas.", category: "Production"),
        Word(term: "Choke", definition: "A device in a wellhead used to control flow rate and pressure.", category: "Production"),
        Word(term: "Separator", definition: "Vessel that separates gas, oil, and water from a produced fluid stream.", category: "Production"),
        Word(term: "Pipeline Pig", definition: "A device sent through a pipeline to clean, inspect, or maintain it.", category: "Midstream"),
    ]
}

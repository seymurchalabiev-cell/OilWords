import SwiftUI

struct QuizView: View {
    @EnvironmentObject var store: WordStore
    @Environment(\.dismiss) private var dismiss

    @State private var questions: [QuizQuestion] = []
    @State private var currentIndex = 0
    @State private var selectedAnswer: String? = nil
    @State private var score = 0
    @State private var showResult = false
    @State private var quizMode: QuizMode = .definitionToTerm

    enum QuizMode: String, CaseIterable {
        case definitionToTerm = "Definition → Term"
        case termToDefinition = "Term → Definition"
    }

    struct QuizQuestion {
        let word: Word
        let prompt: String
        let correctAnswer: String
        let options: [String]
    }

    private var current: QuizQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var body: some View {
        NavigationView {
            Group {
                if questions.isEmpty {
                    notEnoughWordsView
                } else if showResult {
                    resultView
                } else if let q = current {
                    questionView(q)
                }
            }
            .navigationTitle("Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(QuizMode.allCases, id: \.self) { mode in
                            Button {
                                quizMode = mode
                                buildQuiz()
                            } label: {
                                Label(mode.rawValue, systemImage: quizMode == mode ? "checkmark" : "")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .onAppear { buildQuiz() }
    }

    // MARK: - Question view

    private func questionView(_ q: QuizQuestion) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Progress
                ProgressView(value: Double(currentIndex), total: Double(questions.count))
                    .tint(.accentColor)
                    .padding(.horizontal)

                Text("\(currentIndex + 1) of \(questions.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                // Prompt
                Text(q.prompt)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)

                // Options
                VStack(spacing: 12) {
                    ForEach(q.options, id: \.self) { option in
                        optionButton(option: option, question: q)
                    }
                }
                .padding(.horizontal)

                if selectedAnswer != nil {
                    Button("Next →") {
                        advance()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.top)
                }
            }
            .padding(.vertical)
        }
    }

    private func optionButton(option: String, question: QuizQuestion) -> some View {
        let isSelected = selectedAnswer == option
        let isCorrect = option == question.correctAnswer
        let isAnswered = selectedAnswer != nil

        var bgColor: Color {
            if !isAnswered { return Color(.secondarySystemBackground) }
            if isCorrect { return .green.opacity(0.15) }
            if isSelected { return .red.opacity(0.15) }
            return Color(.secondarySystemBackground)
        }

        var borderColor: Color {
            if !isAnswered { return Color.clear }
            if isCorrect { return .green }
            if isSelected { return .red }
            return Color.clear
        }

        return Button {
            guard selectedAnswer == nil else { return }
            selectedAnswer = option
            if option == question.correctAnswer { score += 1 }
        } label: {
            HStack {
                Text(option)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
                Spacer()
                if isAnswered {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : (isSelected ? "xmark.circle.fill" : ""))
                        .foregroundColor(isCorrect ? .green : .red)
                }
            }
            .padding()
            .background(bgColor)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor, lineWidth: 2))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .disabled(isAnswered)
    }

    // MARK: - Result view

    private var resultView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: scoreIcon)
                .font(.system(size: 70))
                .foregroundColor(scoreColor)

            Text(scoreMessage)
                .font(.title.bold())

            Text("\(score) / \(questions.count) correct")
                .font(.title3)
                .foregroundColor(.secondary)

            VStack(spacing: 4) {
                ForEach(questions.indices, id: \.self) { i in
                    let q = questions[i]
                    HStack {
                        Image(systemName: questionWasCorrect(index: i) ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(questionWasCorrect(index: i) ? .green : .red)
                        Text(q.word.term)
                            .font(.subheadline)
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .padding(.horizontal)

            Spacer()

            Button("Restart Quiz") {
                buildQuiz()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }

    private var notEnoughWordsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.yellow)
            Text("Not enough words")
                .font(.title3.bold())
            Text("Add at least 4 words to start a quiz.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Helpers

    private var scoreIcon: String {
        let ratio = Double(score) / Double(questions.count)
        if ratio >= 0.8 { return "star.fill" }
        if ratio >= 0.5 { return "hand.thumbsup.fill" }
        return "arrow.clockwise"
    }

    private var scoreColor: Color {
        let ratio = Double(score) / Double(questions.count)
        if ratio >= 0.8 { return .yellow }
        if ratio >= 0.5 { return .green }
        return .orange
    }

    private var scoreMessage: String {
        let ratio = Double(score) / Double(questions.count)
        if ratio >= 0.8 { return "Excellent!" }
        if ratio >= 0.5 { return "Good job!" }
        return "Keep practicing!"
    }

    @State private var answeredCorrectly: [Bool] = []

    private func questionWasCorrect(index: Int) -> Bool {
        guard index < answeredCorrectly.count else { return false }
        return answeredCorrectly[index]
    }

    private func advance() {
        let wasCorrect = selectedAnswer == current?.correctAnswer
        answeredCorrectly.append(wasCorrect)
        selectedAnswer = nil
        currentIndex += 1
        if currentIndex >= questions.count {
            showResult = true
        }
    }

    private func buildQuiz() {
        guard store.words.count >= 4 else {
            questions = []
            return
        }
        let shuffled = store.words.shuffled()
        questions = shuffled.map { word in
            let prompt = quizMode == .definitionToTerm ? word.definition : word.term
            let correct = quizMode == .definitionToTerm ? word.term : word.definition
            let distractors = Array(shuffled
                .filter { $0.id != word.id }
                .prefix(3)
                .map { quizMode == .definitionToTerm ? $0.term : $0.definition })
            let options = (distractors + [correct]).shuffled()
            return QuizQuestion(word: word, prompt: prompt, correctAnswer: correct, options: options)
        }
        currentIndex = 0
        score = 0
        selectedAnswer = nil
        showResult = false
        answeredCorrectly = []
    }
}

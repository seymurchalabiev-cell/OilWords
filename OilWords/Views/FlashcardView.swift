import SwiftUI

struct FlashcardView: View {
    @EnvironmentObject var store: WordStore
    @Environment(\.dismiss) private var dismiss

    @State private var deck: [Word] = []
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var knownCount = 0
    @State private var unknownCount = 0
    @State private var isFinished = false

    private var current: Word? {
        guard currentIndex < deck.count else { return nil }
        return deck[currentIndex]
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Progress indicator
                HStack {
                    Text("\(currentIndex + 1) / \(deck.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Label("\(knownCount)", systemImage: "hand.thumbsup.fill")
                        .foregroundColor(.green)
                    Label("\(unknownCount)", systemImage: "hand.thumbsdown.fill")
                        .foregroundColor(.red)
                }
                .padding(.horizontal)

                if isFinished {
                    finishedView
                } else if let card = current {
                    // Flashcard
                    ZStack {
                        cardBack(word: card)
                            .opacity(isFlipped ? 1 : 0)
                            .rotation3DEffect(.degrees(isFlipped ? 0 : -90), axis: (x: 0, y: 1, z: 0))

                        cardFront(word: card)
                            .opacity(isFlipped ? 0 : 1)
                            .rotation3DEffect(.degrees(isFlipped ? 90 : 0), axis: (x: 0, y: 1, z: 0))
                    }
                    .offset(offset)
                    .rotationEffect(.degrees(Double(offset.width / 20)))
                    .gesture(dragGesture)
                    .animation(.easeInOut(duration: 0.3), value: isFlipped)
                    .animation(.interactiveSpring(), value: offset)
                    .onTapGesture { isFlipped.toggle() }

                    Text("Tap to flip • Swipe to rate")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    // Action buttons
                    HStack(spacing: 40) {
                        actionButton(icon: "xmark.circle.fill", color: .red, label: "Don't know") {
                            swipe(known: false)
                        }
                        actionButton(icon: "checkmark.circle.fill", color: .green, label: "Know it") {
                            swipe(known: true)
                        }
                    }
                }

                Spacer()
            }
            .padding(.top)
            .navigationTitle("Flashcards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { resetDeck() } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear { resetDeck() }
    }

    // MARK: - Card faces

    private func cardFront(word: Word) -> some View {
        VStack(spacing: 12) {
            Text(word.category)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.accentColor.opacity(0.15))
                .foregroundColor(.accentColor)
                .clipShape(Capsule())

            Spacer()
            Text(word.term)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding()
            Spacer()

            Text("Tap to see definition")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal, 24)
    }

    private func cardBack(word: Word) -> some View {
        VStack(spacing: 12) {
            Text(word.term)
                .font(.title3.bold())
                .foregroundColor(.accentColor)

            Divider()

            ScrollView {
                Text(word.definition)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal, 24)
    }

    // MARK: - Finished screen

    private var finishedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)

            Text("Session Complete!")
                .font(.title.bold())

            VStack(spacing: 8) {
                Label("Known: \(knownCount)", systemImage: "hand.thumbsup.fill")
                    .foregroundColor(.green)
                Label("Unknown: \(unknownCount)", systemImage: "hand.thumbsdown.fill")
                    .foregroundColor(.red)
            }
            .font(.title3)

            Button("Restart") {
                resetDeck()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }

    // MARK: - Drag gesture

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = value.translation
            }
            .onEnded { value in
                if value.translation.width > 120 {
                    swipe(known: true)
                } else if value.translation.width < -120 {
                    swipe(known: false)
                } else {
                    offset = .zero
                }
            }
    }

    // MARK: - Helpers

    private func actionButton(icon: String, color: Color, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .foregroundColor(color)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
    }

    private func swipe(known: Bool) {
        if known { knownCount += 1 } else { unknownCount += 1 }
        if known {
            store.toggleLearned(deck[currentIndex])
        }
        withAnimation(.easeOut(duration: 0.25)) {
            offset = CGSize(width: known ? 500 : -500, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            offset = .zero
            isFlipped = false
            currentIndex += 1
            if currentIndex >= deck.count {
                isFinished = true
            }
        }
    }

    private func resetDeck() {
        let unlearned = store.words.filter { !$0.isLearned }
        deck = (unlearned.isEmpty ? store.words : unlearned).shuffled()
        currentIndex = 0
        knownCount = 0
        unknownCount = 0
        isFlipped = false
        isFinished = false
        offset = .zero
    }
}

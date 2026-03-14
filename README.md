# OilWords 🛢️

An iPhone app for learning oil industry vocabulary, built with **SwiftUI** and targeting **iOS 16+**.

---

## Features

| Feature | Description |
|---|---|
| 📋 **Word List** | Browse all words with search and category filter |
| ➕ **Add / Edit Words** | Add your own terms and definitions; tap a word to edit |
| ✅ **Mark as Learned** | Track which words you know; progress ring on the main screen |
| 🃏 **Flashcards** | Swipe-based flashcard session (right = know it, left = don't know) |
| ❓ **Quiz** | Multiple-choice quiz in two modes: *Definition → Term* or *Term → Definition* |
| 💾 **Persistence** | All words are saved locally with `UserDefaults` |
| 🗂️ **Categories** | Organize words into custom categories (Drilling, Reservoir, Production…) |

---

## Project Structure

```
OilWords/
├── OilWords.xcodeproj/         # Xcode project
└── OilWords/
    ├── OilWordsApp.swift        # App entry point (@main)
    ├── ContentView.swift        # Root view
    ├── Info.plist
    ├── Assets.xcassets/
    ├── Models/
    │   ├── Word.swift           # Word data model (Codable, Identifiable)
    │   └── WordStore.swift      # ObservableObject — CRUD + persistence + sample data
    └── Views/
        ├── WordListView.swift   # Main list with search, filter, progress
        ├── AddWordView.swift    # Add / edit word form
        ├── FlashcardView.swift  # Swipe-based flashcard study
        └── QuizView.swift       # Multiple-choice quiz
```

---

## Getting Started

1. Open `OilWords.xcodeproj` in **Xcode 15** or later.
2. Select an iPhone simulator (iOS 16+) or a real device.
3. Press **⌘R** to build and run.

The app ships with 20 sample oil industry terms so you can start studying immediately. Add your own words using the **+** button.

---

## Requirements

- Xcode 15+
- iOS 16.0+
- Swift 5.9+
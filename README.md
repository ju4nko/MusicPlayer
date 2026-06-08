# MusicPlayer

A native macOS music player built with SwiftUI and the MVVM architecture. This is a personal learning project to practice modern SwiftUI patterns, the Observation framework, and AVFoundation on macOS.

## Goals

- Build a fully native macOS app (no Catalyst, no cross-platform shortcuts).
- Apply a clean MVVM separation between Models, ViewModels and Views.
- Use modern Swift concurrency (`async/await`) instead of Combine.
- Use the modern `@Observable` macro instead of `ObservableObject` / `@Published`.

## Tech stack

- **Language:** Swift 5.9+
- **UI:** SwiftUI
- **State:** `@Observable` (Observation framework)
- **Audio:** AVFoundation (`AVAudioPlayer`)
- **File picking:** AppKit (`NSOpenPanel`)
- **Concurrency:** Swift Concurrency (`async/await`, `@MainActor`)

## Architecture

The project follows MVVM with a strict separation of responsibilities:

```
MusicPlayer/
├── Models/         Pure data structures (Song, ...). No UI, no AVFoundation.
├── ViewModels/     Observable state + business logic. Owns the AVAudioPlayer.
└── Views/          SwiftUI views. Read state from the ViewModel, dispatch actions.
```

Rules of thumb:

- The View observes the ViewModel. The ViewModel does not know the View exists.
- ViewModels are `@MainActor @Observable class` to guarantee UI updates on the main thread.
- Models are immutable `struct`s, ideally `Identifiable` and `Hashable`.

## Roadmap

- [x] `Song` model
- [ ] `PlayerViewModel` with play / pause / seek
- [ ] Library loading via `NSOpenPanel`
- [ ] Now-playing UI with progress slider
- [ ] Track metadata (title, artist, duration, artwork) from AVFoundation
- [ ] Next / previous track
- [ ] Persisted library between launches
- [ ] Unit tests for the ViewModel

## Requirements

- macOS 14 (Sonoma) or later
- Xcode 15 or later

## Build and run

1. Open `MusicPlayer.xcodeproj` in Xcode.
2. Select the `MusicPlayer` scheme.
3. Run with `Cmd + R`.

## Project status

Work in progress. This repository is being built incrementally as a learning exercise, so the feature set and code organization will evolve commit by commit.

## License

No license has been declared yet. Until a license is added, all rights are reserved by the author.

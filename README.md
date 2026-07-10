# PlayHub

PlayHub is a SwiftUI iOS app built from the Week 4 "The Real App" brief. It wraps three game modes in a proper app shell with persistence, statistics, map pins, notification scheduling, score sharing, and reset controls.

## Architecture

The project is organized around the structure requested in the slides:

- `App/` contains the SwiftUI app entry point and root tab shell.
- `Models/` contains `GameMode`, `GameSession`, and `TriviaQuestion`.
- `ViewModels/` contains one view model per game plus `StatsVM`.
- `Services/` contains wrappers for location, notifications, and trivia content.
- `Views/Tabs/` contains Home, Stats, Map, and Settings tabs.
- `Views/Games/` contains Tap Frenzy, Light It Up, and Quiz Rush.
- `Views/Shared/` contains reusable result and score UI.

Each completed game appends a `GameSession` with mode, score, timestamp, latitude, and longitude. Sessions are encoded as JSON and stored in `UserDefaults`.

## Features

- Four-tab `TabView`: Home, Stats, Map, and Settings.
- Three playable modes: Tap Frenzy, Light It Up, and Quiz Rush.
- Stats aggregation across all modes with totals, best scores, recent games, and a Swift Charts bar chart.
- MapKit screen with one pin per completed game session.
- Core Location permission request and location capture for new sessions.
- Daily challenge local notification scheduled from Settings.
- ShareLink on every result screen.
- Reset-all-stats button with a confirmation dialog.

## Known Limitations

- Quiz Rush fetches ten fresh multiple-choice questions from Open Trivia DB, with a genre picker, loading and retry states, answer feedback, wrong-answer beep, and streak bonuses.
- If location permission is denied or unavailable, new sessions use a Colombo fallback coordinate so the map feature still remains testable.
- The app targets iOS 17 because it uses modern SwiftUI map, chart, and content-unavailable APIs.

## Reflection

The main goal was to turn three separate modes into a structured app rather than a collection of screens. The shared `StatsVM` is the center of the project: games only report final scores, and the rest of the app reads the same saved sessions for charts, lists, and map pins. Keeping platform features in small services makes the code easier to explain during a walkthrough.

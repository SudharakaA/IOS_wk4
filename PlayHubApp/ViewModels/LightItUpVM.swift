import Foundation

@MainActor
final class LightItUpVM: ObservableObject {
    @Published private(set) var score = 0
    @Published private(set) var level = 1
    @Published private(set) var lives = 3
    @Published private(set) var timeRemaining = 30
    @Published private(set) var highlightedTile: Int?
    @Published private(set) var isRunning = false
    @Published private(set) var finalScore: Int?

    private var correctTapsThisLevel = 0
    private var timer: Timer?
    private var nextTileTask: Task<Void, Never>?

    deinit {
        timer?.invalidate()
        nextTileTask?.cancel()
    }

    func start() {
        timer?.invalidate()
        nextTileTask?.cancel()
        score = 0
        level = 1
        lives = 3
        timeRemaining = 30
        correctTapsThisLevel = 0
        finalScore = nil
        isRunning = true
        showNextTile()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    func startIfNeeded() {
        guard !isRunning, finalScore == nil else { return }
        start()
    }

    func tap(tile: Int) {
        guard isRunning, finalScore == nil else { return }

        guard tile == highlightedTile else {
            lives -= 1
            if lives == 0 {
                finish()
            }
            return
        }

        score += 10 * level
        correctTapsThisLevel += 1
        highlightedTile = nil

        if correctTapsThisLevel == 5 {
            level += 1
            correctTapsThisLevel = 0
            timeRemaining = max(12, 30 - (level - 1) * 2)
        }

        nextTileTask?.cancel()
        nextTileTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(260))
            guard !Task.isCancelled else { return }
            self?.showNextTile()
        }
    }

    private func showNextTile() {
        guard isRunning else { return }
        var next = Int.random(in: 0..<6)
        if let highlightedTile, next == highlightedTile {
            next = (next + Int.random(in: 1..<6)) % 6
        }
        highlightedTile = next
    }

    private func tick() {
        guard isRunning else { return }
        if timeRemaining > 1 {
            timeRemaining -= 1
        } else {
            timeRemaining = 0
            finish()
        }
    }

    private func finish() {
        timer?.invalidate()
        timer = nil
        nextTileTask?.cancel()
        highlightedTile = nil
        isRunning = false
        finalScore = score
    }
}

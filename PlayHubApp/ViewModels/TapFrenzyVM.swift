import Foundation

@MainActor
final class TapFrenzyVM: ObservableObject {
    @Published private(set) var score = 0
    @Published private(set) var timeRemaining = 10
    @Published private(set) var isRunning = false
    @Published private(set) var finalScore: Int?

    private var timer: Timer?

    func start() {
        score = 0
        timeRemaining = 10
        finalScore = nil
        isRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    func tap() {
        guard isRunning else { return }
        score += 1
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        finalScore = score
    }

    private func tick() {
        guard isRunning else { return }
        if timeRemaining > 1 {
            timeRemaining -= 1
        } else {
            timeRemaining = 0
            stop()
        }
    }
}

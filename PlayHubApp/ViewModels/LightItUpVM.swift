import Foundation

@MainActor
final class LightItUpVM: ObservableObject {
    enum Phase: Equatable {
        case ready
        case showing
        case choosing
    }

    @Published private(set) var score = 0
    @Published private(set) var round = 0
    @Published private(set) var phase: Phase = .ready
    @Published private(set) var highlightedTile: Int?
    @Published private(set) var finalScore: Int?

    private var targetTile = 0
    private var roundTask: Task<Void, Never>?

    deinit {
        roundTask?.cancel()
    }

    func start() {
        roundTask?.cancel()
        score = 0
        round = 0
        finalScore = nil
        beginRound()
    }

    func choose(tile: Int) {
        guard phase == .choosing, finalScore == nil else { return }

        if tile == targetTile {
            score += 10
            round += 1
            highlightedTile = tile
            phase = .showing
            roundTask = Task { [weak self] in
                try? await Task.sleep(for: .milliseconds(260))
                guard !Task.isCancelled else { return }
                self?.beginRound()
            }
        } else {
            finalScore = score
        }
    }

    private func beginRound() {
        targetTile = Int.random(in: 0..<3)
        highlightedTile = nil
        phase = .showing

        roundTask?.cancel()
        roundTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(420))
            guard let self, !Task.isCancelled else { return }

            self.highlightedTile = self.targetTile
            try? await Task.sleep(for: .milliseconds(700))
            guard !Task.isCancelled else { return }

            self.highlightedTile = nil
            self.phase = .choosing
        }
    }
}

import AudioToolbox
import Foundation
import UIKit

enum QuizRushPhase: Equatable {
    case setup
    case loading
    case playing
    case feedback
    case error(String)
}

@MainActor
final class QuizRushVM: ObservableObject {
    @Published private(set) var phase: QuizRushPhase = .setup
    @Published private(set) var currentQuestion: TriviaQuestion?
    @Published private(set) var score = 0
    @Published private(set) var streak = 0
    @Published private(set) var questionNumber = 0
    @Published private(set) var selectedAnswer: String?
    @Published private(set) var wasCorrect: Bool?
    @Published private(set) var finalScore: Int?
    @Published var selectedGenre: TriviaGenre = .mixed

    private let triviaAPI = TriviaAPI()
    private var questions: [TriviaQuestion] = []

    var streakBonus: Int {
        guard streak > 1 else { return 0 }
        return min(streak * 2, 10)
    }

    var nextCorrectBonus: Int {
        let nextStreak = streak + 1
        guard nextStreak > 1 else { return 0 }
        return min(nextStreak * 2, 10)
    }

    func start() {
        Task { await loadRound() }
    }

    func answer(_ option: String) {
        guard phase == .playing, let question = currentQuestion else { return }

        selectedAnswer = option
        let correct = option == question.answer
        wasCorrect = correct

        if correct {
            streak += 1
            score += 10 + streakBonus
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else {
            score = max(0, score - 2)
            streak = 0
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            AudioServicesPlaySystemSound(1053)
        }

        phase = .feedback
    }

    func continueRound() {
        guard phase == .feedback else { return }

        if questionNumber >= 10 {
            finalScore = score
            return
        }

        showNextQuestion()
    }

    func resetToGenreSelection() {
        phase = .setup
        currentQuestion = nil
        selectedAnswer = nil
        wasCorrect = nil
        finalScore = nil
    }

    private func loadRound() async {
        phase = .loading
        currentQuestion = nil
        finalScore = nil
        score = 0
        streak = 0
        questionNumber = 0
        selectedAnswer = nil
        wasCorrect = nil

        do {
            questions = try await triviaAPI.fetchQuestions(for: selectedGenre)
            showNextQuestion()
        } catch {
            phase = .error(error.localizedDescription)
        }
    }

    private func showNextQuestion() {
        guard !questions.isEmpty else {
            phase = .error(TriviaAPIError.noQuestions.localizedDescription)
            return
        }

        currentQuestion = questions.removeFirst()
        questionNumber += 1
        selectedAnswer = nil
        wasCorrect = nil
        phase = .playing
    }
}

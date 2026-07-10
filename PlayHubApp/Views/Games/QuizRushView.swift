import SwiftUI

struct QuizRushView: View {
    @EnvironmentObject private var stats: StatsVM
    @EnvironmentObject private var location: LocationService
    @StateObject private var viewModel = QuizRushVM()
    @State private var savedFinalScore: Int?

    var body: some View {
        ZStack {
            PlayHubBackground()

            if let score = savedFinalScore {
                ResultView(mode: .quizRush, score: score) {
                    savedFinalScore = nil
                    viewModel.resetToGenreSelection()
                }
            } else {
                ScrollView {
                    VStack(spacing: 18) {
                        quizHeader
                        content
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.finalScore) { _, score in
            guard let score else { return }
            location.requestFreshLocation()
            stats.append(mode: .quizRush, score: score, coordinate: location.coordinateForSession())
            savedFinalScore = score
        }
    }

    private var quizHeader: some View {
        GameHeaderView(
            mode: .quizRush,
            subtitle: "10 questions • +10 points • streaks earn bonus points"
        )
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.phase {
        case .setup:
            genrePicker
        case .loading:
            loadingView
        case .playing, .feedback:
            gameBoard
        case .error(let message):
            errorView(message: message)
        }
    }

    private var genrePicker: some View {
        FriendlyPanel(color: GameMode.quizRush.accent) {
            VStack(alignment: .leading, spacing: 8) {
                Label("Choose your quiz genre", systemImage: "square.grid.2x2.fill")
                    .font(.title3.bold())
                Text("We’ll fetch a fresh ten-question round just for you.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(TriviaGenre.allCases) { genre in
                    Button { viewModel.selectedGenre = genre } label: {
                        HStack(spacing: 8) {
                            Image(systemName: genre.icon)
                            Text(genre.rawValue)
                                .lineLimit(1)
                            Spacer(minLength: 0)
                            if viewModel.selectedGenre == genre {
                                Image(systemName: "checkmark.circle.fill")
                            }
                        }
                        .font(.subheadline.weight(.semibold))
                        .padding(12)
                        .foregroundStyle(viewModel.selectedGenre == genre ? .white : Color.playHubInk)
                        .background(viewModel.selectedGenre == genre ? GameMode.quizRush.accent : .white.opacity(0.7), in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }

            Button { viewModel.start() } label: {
                Label("Start \(viewModel.selectedGenre.rawValue) Quiz", systemImage: "play.fill")
            }
            .buttonStyle(PrimaryGameButtonStyle(color: GameMode.quizRush.tint))
        }
    }

    private var loadingView: some View {
        FriendlyPanel(color: GameMode.quizRush.tint) {
            VStack(spacing: 16) {
                ProgressView()
                    .controlSize(.large)
                    .tint(GameMode.quizRush.accent)
                Text("Building your \(viewModel.selectedGenre.rawValue.lowercased()) quiz…")
                    .font(.headline)
                Text("Fetching 10 fresh questions from Open Trivia DB")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
        }
    }

    private var gameBoard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ScoreBadge(title: "Question", value: "\(viewModel.questionNumber)/10", systemImage: "list.number", color: GameMode.quizRush.accent)
                ScoreBadge(title: "Score", value: "\(viewModel.score)", systemImage: "star.fill", color: GameMode.quizRush.tint)
                ScoreBadge(title: "Streak", value: "×\(viewModel.streak)", systemImage: "flame.fill", color: .playHubCoral)
            }

            if let question = viewModel.currentQuestion {
                FriendlyPanel(color: GameMode.quizRush.tint) {
                    HStack {
                        Label(question.category, systemImage: "tag.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(GameMode.quizRush.accent)
                        Spacer()
                        if viewModel.nextCorrectBonus > 0 {
                            Text("Next correct: +\(viewModel.nextCorrectBonus) bonus")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.playHubCoral)
                        }
                    }

                    Text(question.prompt)
                        .font(.title3.bold())
                        .foregroundStyle(Color.playHubInk)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 10) {
                        ForEach(Array(question.options.enumerated()), id: \.element) { index, option in
                            AnswerButton(
                                label: option,
                                index: index,
                                state: answerState(for: option, question: question)
                            ) {
                                viewModel.answer(option)
                            }
                            .disabled(viewModel.phase == .feedback)
                        }
                    }

                    if viewModel.phase == .feedback {
                        feedbackCard(question: question)
                    }
                }
            }
        }
    }

    private func feedbackCard(question: TriviaQuestion) -> some View {
        let correct = viewModel.wasCorrect == true
        return VStack(alignment: .leading, spacing: 10) {
            Label(correct ? "Correct!" : "Not quite", systemImage: correct ? "checkmark.seal.fill" : "xmark.octagon.fill")
                .font(.headline)
                .foregroundStyle(correct ? Color.playHubLeaf : Color.playHubCoral)
            Text(correct ? "Great work — your streak is now ×\(viewModel.streak)." : "The correct answer is: \(question.answer)")
                .font(.subheadline)
                .foregroundStyle(Color.playHubInk)
            Button { viewModel.continueRound() } label: {
                Label(viewModel.questionNumber == 10 ? "See Results" : "Next Question", systemImage: viewModel.questionNumber == 10 ? "flag.checkered" : "arrow.right")
            }
            .buttonStyle(PrimaryGameButtonStyle(color: correct ? .playHubLeaf : GameMode.quizRush.accent))
        }
        .padding(14)
        .background((correct ? Color.playHubLeaf : Color.playHubCoral).opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
    }

    private func answerState(for option: String, question: TriviaQuestion) -> AnswerButton.State {
        guard viewModel.phase == .feedback else { return .idle }
        if option == question.answer { return .correct }
        if option == viewModel.selectedAnswer { return .incorrect }
        return .dimmed
    }

    private func errorView(message: String) -> some View {
        FriendlyPanel(color: .playHubCoral) {
            VStack(spacing: 14) {
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 38))
                    .foregroundStyle(Color.playHubCoral)
                Text("Couldn’t load the quiz")
                    .font(.title3.bold())
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button { viewModel.start() } label: {
                    Label("Try Again", systemImage: "arrow.clockwise")
                }
                .buttonStyle(PrimaryGameButtonStyle(color: .playHubCoral))

                Button("Change Genre") { viewModel.resetToGenreSelection() }
                    .font(.subheadline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.vertical, 14)
        }
    }
}

private struct AnswerButton: View {
    enum State { case idle, correct, incorrect, dimmed }

    let label: String
    let index: Int
    let state: State
    let action: () -> Void

    private var color: Color {
        switch state {
        case .idle: return GameMode.quizRush.accent
        case .correct: return .playHubLeaf
        case .incorrect: return .playHubCoral
        case .dimmed: return .gray
        }
    }

    private var icon: String {
        switch state {
        case .correct: return "checkmark.circle.fill"
        case .incorrect: return "xmark.circle.fill"
        case .idle, .dimmed: return "\(index + 1).circle.fill"
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                Text(label)
                    .font(.subheadline.weight(.semibold))
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .foregroundStyle(state == .dimmed ? Color.secondary : Color.white)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(state == .dimmed ? Color.gray.opacity(0.12) : color, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

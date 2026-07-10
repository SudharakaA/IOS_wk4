import Foundation

struct TriviaQuestion: Identifiable, Equatable {
    let id: UUID
    let prompt: String
    let options: [String]
    let answer: String
    let category: String

    init(
        id: UUID = UUID(),
        prompt: String,
        options: [String],
        answer: String,
        category: String = "Trivia"
    ) {
        self.id = id
        self.prompt = prompt
        self.options = options
        self.answer = answer
        self.category = category
    }
}

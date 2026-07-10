import Foundation

enum TriviaGenre: String, CaseIterable, Identifiable {
    case mixed = "Mixed"
    case generalKnowledge = "General"
    case entertainment = "Entertainment"
    case science = "Science"
    case history = "History"
    case geography = "Geography"
    case sports = "Sports"
    case gaming = "Gaming"

    var id: String { rawValue }

    var categoryID: Int? {
        switch self {
        case .mixed: return nil
        case .generalKnowledge: return 9
        case .entertainment: return 11
        case .science: return 17
        case .history: return 23
        case .geography: return 22
        case .sports: return 21
        case .gaming: return 15
        }
    }

    var icon: String {
        switch self {
        case .mixed: return "sparkles"
        case .generalKnowledge: return "brain.head.profile"
        case .entertainment: return "film.fill"
        case .science: return "atom"
        case .history: return "building.columns.fill"
        case .geography: return "globe.americas.fill"
        case .sports: return "figure.run"
        case .gaming: return "gamecontroller.fill"
        }
    }
}

enum TriviaAPIError: LocalizedError {
    case invalidResponse
    case noQuestions

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "We couldn't read the trivia service response."
        case .noQuestions:
            return "There aren't enough questions in that category right now."
        }
    }
}

struct TriviaAPI {
    func fetchQuestions(for genre: TriviaGenre) async throws -> [TriviaQuestion] {
        var components = URLComponents(string: "https://opentdb.com/api.php")!
        components.queryItems = [
            URLQueryItem(name: "amount", value: "10"),
            URLQueryItem(name: "type", value: "multiple")
        ]

        if let categoryID = genre.categoryID {
            components.queryItems?.append(URLQueryItem(name: "category", value: "\(categoryID)"))
        }

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw TriviaAPIError.invalidResponse
        }

        let payload = try JSONDecoder().decode(TriviaResponse.self, from: data)
        guard payload.responseCode == 0, payload.results.count == 10 else {
            throw TriviaAPIError.noQuestions
        }

        return payload.results.map { result in
            let answer = result.correctAnswer.decodingHTMLEntities
            return TriviaQuestion(
                prompt: result.question.decodingHTMLEntities,
                options: (result.incorrectAnswers.map(\.decodingHTMLEntities) + [answer]).shuffled(),
                answer: answer,
                category: result.category.decodingHTMLEntities
            )
        }
    }
}

private struct TriviaResponse: Decodable {
    let responseCode: Int
    let results: [TriviaResult]

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}

private struct TriviaResult: Decodable {
    let category: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]

    enum CodingKeys: String, CodingKey {
        case category, question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}

private extension String {
    var decodingHTMLEntities: String {
        guard let data = data(using: .utf8) else { return self }
        return (try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil
        ))?.string ?? self
    }
}

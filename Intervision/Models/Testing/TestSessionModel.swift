//
//  TestSessionModel.swift
//  Intervision
//
//  Created by Reuben on 26/04/2024.
//

import Foundation

struct TestSession: Identifiable, Codable {
    let tester: Tester
    let questionCount: Int
    let questions: [Question]
    let dateTimeStarted: Date
    
    var results: [TestResult]
    
    // Identifiable
    let id: UUID

    init(
        tester: Tester,
        questionCount: Int
    ) {
        self.tester = tester
        self.questionCount = questionCount
        self.questions = TestSession.generateQuestions(questionCount: questionCount)
        self.results = []
        self.dateTimeStarted = Date()
        self.id = UUID()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(tester.id.uuidString, forKey: .___tester_id)
        try container.encode(id.uuidString, forKey: .__test_id)
        try container.encode(tester.skills, forKey: ._skills)
        try container.encode(results, forKey: .results)
    }

    enum CodingKeys: String, CodingKey {
        case ___tester_id, __test_id, _skills, results
    }
    
    init(from decoder: Decoder) throws {
        self.tester = Tester(skills: [], id: UUID())
        self.questionCount = 0
        self.questions = []
        self.results = []
        self.dateTimeStarted = Date()
        self.id = UUID()
    }
    
    private static func generateQuestions(questionCount: Int) -> [Question] {
        var questions: [Question] = []
        
        for _ in 0..<(max(1, questionCount / (3 * Question.QuestionType.allCases.count))) {
            for questionType in Question.QuestionType.allCases {
                if questionType.isScoreQuestion {
                    let scoreQuestions = Array(repeating: Question(type: questionType, intervalLinesType: .None), count: 3)
                    
                    questions.append(contentsOf: scoreQuestions)
                } else {
                    for linesType in Question.IntervalLinesType.allCases {
                        let rollQuestion = Question(type: questionType, intervalLinesType: linesType)
                        
                        questions.append(rollQuestion)
                    }
                }
            }
        }
        
        questions.shuffle()
        
        return questions
    }
}

struct TestResult: Codable {
    let question: Question
    let answeredCorrectly: Bool
    let timeTaken: Double
}

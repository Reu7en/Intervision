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
    let dateTimeStarted: Date
    
    var questions: [Question]
    var results: [TestResult]
    var random = false
    
    // Identifiable
    let id: UUID

    init(
        tester: Tester,
        questionCount: Int
    ) {
        self.tester = tester
        self.questionCount = questionCount
        self.questions = TestSession.generateRandomQuestions(questionCount: questionCount)
        self.results = []
        self.dateTimeStarted = Date()
        self.id = UUID()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(tester.id.uuidString, forKey: ._____tester_id)
        try container.encode(id.uuidString, forKey: .____test_session_id)
        try container.encode(tester.skills, forKey: .___skills)
        try container.encode(random, forKey: .__random_test_questions)
        try container.encode(dateTimeStarted, forKey: ._time_started)
        try container.encode(results, forKey: .results)
    }

    enum CodingKeys: String, CodingKey {
        case _____tester_id, ____test_session_id, ___skills, __random_test_questions, _time_started, results
    }
    
    init(from decoder: Decoder) throws {
        self.tester = Tester(skills: [], id: UUID())
        self.questionCount = 0
        self.questions = []
        self.results = []
        self.dateTimeStarted = Date()
        self.id = UUID()
    }
    
    private static func generateRandomQuestions(questionCount: Int) -> [Question] {
        var questions: [Question] = []
        
        for questionType in Question.QuestionType.allCases {
            if questionType.isScoreQuestion {
                let scoreQuestions = Array(repeating: Question(type: questionType, intervalLinesType: .None), count: 2)
                
                questions.append(contentsOf: scoreQuestions)
            } else {
                for linesType in Question.IntervalLinesType.allCases.filter( { $0 != .None } ) {
                    let rollQuestion = Question(type: questionType, intervalLinesType: linesType)
                    
                    questions.append(rollQuestion)
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

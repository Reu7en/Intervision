//
//  TestSessionModel.swift
//  Intervision
//
//  Created by Reuben on 26/04/2024.
//

import Foundation

struct TestSession: Identifiable {
    let tester: Tester
    let questionCount: Int
    let questions: [Question]
    let dateTimeStarted: Date
    
    var results: [(Question, Bool, Double)]
    
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
    
    private static func generateQuestions(questionCount: Int) -> [Question] {
        var questions: [Question] = []
        
        for _ in 0..<(questionCount / (3 * Question.QuestionType.allCases.count)) {
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

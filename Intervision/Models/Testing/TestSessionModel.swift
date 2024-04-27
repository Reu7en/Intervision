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
    
    var questions: [Question] {
        generateQuestions()
    }
    
    var results: [(Question, Bool, Double)]
    
    // Identifiable
    let id: UUID

    init(
        tester: Tester,
        questionCount: Int
    ) {
        self.tester = tester
        self.questionCount = questionCount
        self.results = []
        self.id = UUID()
    }
    
    private func generateQuestions() -> [Question] {
        var questions: [Question] = []
        
        for _ in 0..<(questionCount / 30) {
            let scoreQuestions = Question.QuestionType.allCases.filter { $0.isScoreQuestion }
            questions.append(contentsOf: scoreQuestions.flatMap { questionType in
                Array(repeating: Question(type: questionType), count: 3)
            })

            let otherQuestions = Question.QuestionType.allCases.filter { !$0.isScoreQuestion }
            questions.append(contentsOf: otherQuestions.map { Question(type: $0) })
        }
        
        questions.shuffle()
        
        return questions
    }
}

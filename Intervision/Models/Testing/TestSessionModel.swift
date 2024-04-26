//
//  TestSessionModel.swift
//  Intervision
//
//  Created by Reuben on 26/04/2024.
//

import Foundation

struct TestSession: Identifiable {
    let tester: Tester
    let testCount: Int
    
    var questionsRemaining: [(Question.QuestionType, Int)]
    var results: [(Question, Bool, Double)]
    
    // Identifiable
    let id: UUID

    init(
        tester: Tester,
        testCount: Int
    ) {
        self.tester = tester
        self.testCount = testCount
        self.results = []
        self.questionsRemaining = Question.QuestionType.allCases.map { ($0, testCount / Question.QuestionType.allCases.count) }
        self.id = UUID()
    }
}

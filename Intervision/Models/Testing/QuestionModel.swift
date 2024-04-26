//
//  QuestionModel.swift
//  Intervision
//
//  Created by Reuben on 26/04/2024.
//

import Foundation

struct Question: Identifiable {
    let type: QuestionType
    
    // Identifiable
    let id: UUID
    
    init(
        type: QuestionType
    ) {
        self.type = type
        self.id = UUID()
    }
}

extension Question {
    enum QuestionType: CaseIterable {
        case ScoreTwoNoteIntervalIdentification
        case RollTwoNoteIntervalIdentification
        case ScoreThreeNoteInnerIntervalsIdentification
        case RollThreeNoteInnerIntervalsIdentification
        case ScoreThreeNoteOuterIntervalIdentification
        case RollThreeNoteOuterIntervalIdentification
        case ScoreChordsAreInversions
        case RollChordsAreInversions
        case BothTwoNoteIntervalsAreEqual
        case BothChordsAreEqual
    }
}

//
//  QuestionModel.swift
//  Intervision
//
//  Created by Reuben on 26/04/2024.
//

import Foundation

struct Question: Identifiable {
    let type: QuestionType
    let intervalLinesType: IntervalLinesType
    
    // Identifiable
    let id: UUID
    
    init(
        type: QuestionType,
        intervalLinesType: IntervalLinesType
    ) {
        self.type = type
        self.intervalLinesType = intervalLinesType
        self.id = UUID()
    }
}

extension Question {
    enum QuestionType: CaseIterable {
        case ScoreTwoNoteIntervalIdentification
        case ScoreThreeNoteInnerIntervalsIdentification
        case ScoreThreeNoteOuterIntervalIdentification
        case ScoreChordsAreInversions
        case ScoreTwoNoteIntervalsAreEqual
        
        case RollTwoNoteIntervalIdentification
        case RollThreeNoteInnerIntervalsIdentification
        case RollThreeNoteOuterIntervalIdentification
        case RollChordsAreInversions
        case RollTwoNoteIntervalsAreEqual
        
        var isScoreQuestion: Bool {
            switch self {
            case .ScoreTwoNoteIntervalIdentification,
                 .ScoreThreeNoteInnerIntervalsIdentification,
                 .ScoreThreeNoteOuterIntervalIdentification,
                 .ScoreChordsAreInversions,
                 .ScoreTwoNoteIntervalsAreEqual:
                return true
            default:
                return false
            }
        }
    }
    
    enum IntervalLinesType: CaseIterable {
        case None
        case Lines
        case InvertedLines
    }
}

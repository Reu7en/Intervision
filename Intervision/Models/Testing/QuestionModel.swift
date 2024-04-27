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
        case ScoreThreeNoteInnerIntervalsIdentification
        case ScoreThreeNoteOuterIntervalIdentification
        case ScoreChordsAreInversions
        
        case RollTwoNoteIntervalIdentificationNoLines
        case RollTwoNoteIntervalIdentificationWithLines
        case RollTwoNoteIntervalIdentificationWithInvertedLines
        case RollThreeNoteInnerIntervalsIdentificationNoLines
        case RollThreeNoteInnerIntervalsIdentificationWithLines
        case RollThreeNoteInnerIntervalsIdentificationWithInvertedLines
        case RollThreeNoteOuterIntervalIdentificationNoLines
        case RollThreeNoteOuterIntervalIdentificationWithLines
        case RollThreeNoteOuterIntervalIdentificationWithInvertedLines
        case RollChordsAreInversionsNoLines
        case RollChordsAreInversionsWithLines
        case RollChordsAreInversionsWithInvertedLines
        
        case BothTwoNoteChordsAreEqualNoLines
        case BothTwoNoteChordsAreEqualWithLines
        case BothTwoNoteChordsAreEqualWithInvertedLines
        case BothThreeNoteChordsAreEqualNoLines
        case BothThreeNoteChordsAreEqualWithLines
        case BothThreeNoteChordsAreEqualWithInvertedLines
        
        var isScoreQuestion: Bool {
            switch self {
            case .ScoreTwoNoteIntervalIdentification,
                 .ScoreThreeNoteInnerIntervalsIdentification,
                 .ScoreThreeNoteOuterIntervalIdentification,
                 .ScoreChordsAreInversions:
                return true
            default:
                return false
            }
        }
    }
}

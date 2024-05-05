//
//  QuestionModel.swift
//  Intervision
//
//  Created by Reuben on 26/04/2024.
//

import Foundation

struct Question: Identifiable, Codable {
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
    enum QuestionType: String, Codable, CaseIterable {
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
        
        case ScoreMelodicIntervalIdentification
        case ScoreSmallestMelodicIntervalIdentification
        case ScoreLargestMelodicIntervalIdentification
        case ScoreMelodicIntervalInversionIdentification
        case ScoreMelodicMovementIdentification
        
        case RollMelodicIntervalIdentification
        case RollSmallestMelodicIntervalIdentification
        case RollLargestMelodicIntervalIdentification
        case RollMelodicIntervalInversionIdentification
        case RollMelodicMovementIdentification
        
        var isScoreQuestion: Bool {
            switch self {
            case .ScoreTwoNoteIntervalIdentification,
                .ScoreThreeNoteInnerIntervalsIdentification,
                .ScoreThreeNoteOuterIntervalIdentification,
                .ScoreChordsAreInversions,
                .ScoreTwoNoteIntervalsAreEqual,
                .ScoreMelodicIntervalIdentification,
                .ScoreSmallestMelodicIntervalIdentification,
                .ScoreLargestMelodicIntervalIdentification,
                .ScoreMelodicIntervalInversionIdentification,
                .ScoreMelodicMovementIdentification:
                return true
            default:
                return false
            }
        }
        
        var isBoolQuestion: Bool {
            switch self {
            case .ScoreChordsAreInversions,
                .ScoreTwoNoteIntervalsAreEqual,
                .RollChordsAreInversions,
                .RollTwoNoteIntervalsAreEqual:
                return true
            default:
                return false
            }
        }
        
        var isMultipartQuestion: Bool {
            switch self {
            case .ScoreThreeNoteInnerIntervalsIdentification, .RollThreeNoteInnerIntervalsIdentification:
                return true
            default:
                return false
            }
        }
        
        var description: [String] {
            switch self {
            case .ScoreTwoNoteIntervalIdentification, .RollTwoNoteIntervalIdentification:
                return ["Identify the harmonic interval formed by these two notes", "", ""]
            case .ScoreThreeNoteInnerIntervalsIdentification, .RollThreeNoteInnerIntervalsIdentification:
                return ["Identify the harmonic intervals between the following", "1. The lowest note and the middle note", "2. The middle note and the highest note"]
            case .ScoreThreeNoteOuterIntervalIdentification, .RollThreeNoteOuterIntervalIdentification:
                return ["Identify the harmonic interval between the lowest note and the highest note", "", ""]
            case .ScoreChordsAreInversions, .RollChordsAreInversions:
                return ["Are these two chords inversions of each other?", "", ""]
            case .ScoreTwoNoteIntervalsAreEqual, .RollTwoNoteIntervalsAreEqual:
                return ["Do these two chords contain the same harmonic interval?", "", ""]
            case .ScoreMelodicIntervalIdentification, .RollMelodicIntervalIdentification:
                return ["Identify the melodic interval formed by these two notes", "", ""]
            case .ScoreSmallestMelodicIntervalIdentification, .RollSmallestMelodicIntervalIdentification:
                return ["Identify the smallest melodic interval in this phrase", "", ""]
            case .ScoreLargestMelodicIntervalIdentification, .RollLargestMelodicIntervalIdentification:
                return ["Identify the largest melodic interval in this phrase", "", ""]
            case .ScoreMelodicIntervalInversionIdentification, .RollMelodicIntervalInversionIdentification:
                return ["Identify the inversion of the melodic interval formed by these two notes", "", ""]
            case .ScoreMelodicMovementIdentification, .RollMelodicMovementIdentification:
                return ["Identify the overall movement in this phrase", "", ""]
            }
        }
    }
    
    enum IntervalLinesType: String, Codable, CaseIterable {
        case None
        case Lines
        case InvertedLines
    }
}

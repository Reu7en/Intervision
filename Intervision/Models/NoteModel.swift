//
//  NoteModel.swift
//  Intervision
//
//  Created by Reuben on 06/02/2024.
//

import Foundation

struct Note: Identifiable, Equatable {
    var pitch: Pitch
    var accidental: Accidental
    var octave: Octave
    var duration: Duration
    var isRest: Bool
    var isDotted: Bool
    var durationValue: Double {
        return isDotted ? self.duration.rawValue * 1.5 : self.duration.rawValue
    }

    // Identifiable
    var id = UUID()
    
    // Equatable
    static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.id == rhs.id
    }
}

// Enums
extension Note {
    enum Pitch: String {
        case C, D, E, F, G, A, B
    }
    
    enum Accidental {
        case Sharp, Flat, Natural, None
    }
    
    enum Octave: Int {
        case subContra = 0
        case contra = 1
        case great = 2
        case small = 3
        case oneLine = 4
        case twoLine = 5
        case threeLine = 6
        case fourLine = 7
        case fiveLine = 8
    }
    
    enum Duration: Double {
        // Standard
        case whole = 1.0
        case half = 0.5
        case quarter = 0.25
        case eighth = 0.125
        case sixteenth = 0.0625
        case thirtySecond = 0.03125
    }
}

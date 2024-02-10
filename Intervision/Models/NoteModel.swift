//
//  NoteModel.swift
//  Intervision
//
//  Created by Reuben on 06/02/2024.
//

import Foundation

struct Note: Identifiable, Equatable {
    var pitch: Pitch?
    var accidental: Accidental?
    var octave: Octave?
    var duration: Duration
    var durationValue: Double
    var timeModification: TimeModification?
    var dynamic: Dynamic?
    var graceNotes: [Grace]?
    var tie: Tie?
    var isRest: Bool
    var isDotted: Bool
    var hasAccent: Bool

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
    
    enum Accidental: String {
        case Sharp, Flat, Natural
        case DoubleSharp, DoubleFlat
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
        case breve = 2.0
        case whole = 1.0
        case half = 0.5
        case quarter = 0.25
        case eighth = 0.125
        case sixteenth = 0.0625
        case thirtySecond = 0.03125
        case sixtyFourth = 0.015625
        case bar = 0.0
    }
    
    enum TimeModification {
        case custom(actual: Int, normal: Int)
    }
    
    enum Dynamic {
        case Fortississimo
        case Fortissimo
        case Forte
        case MezzoForte
        case MezzoPiano
        case Piano
        case Pianissimo
        case Pianississimo
        case CrescendoStart, CrescendoEnd
        case DecrescendoStart, DecrescendoEnd
        case Sforzando
    }
    
    enum Tie {
        case Start
        case Stop
    }
}

extension Note: CustomStringConvertible {
    var description: String {
        var description = "Note: "
        description += "\(pitch?.rawValue ?? "")\(accidental?.rawValue ?? "")\(octave?.rawValue.description ?? "")"
        description += " D: \(duration) Dot: \(isDotted) Rest: \(isRest) Accent: \(hasAccent) Tie: \(String(describing: tie)) TMod: \(String(describing: timeModification))\n"
        return description
    }
}

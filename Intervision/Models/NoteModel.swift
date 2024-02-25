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
    var octaveShift: OctaveShift?
    var duration: Duration
    var durationValue: Double
    var timeModification: TimeModification?
    var dynamic: [Dynamic]?
    var graceNotes: [Grace]?
    var tie: Tie?
    var isRest: Bool
    var isDotted: Bool
    var hasAccent: Bool

    // Identifiable
    var id = UUID()
    
    // Equatable - checks for equal relevant properties rather than id
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.pitch == rhs.pitch &&
               lhs.accidental == rhs.accidental &&
               lhs.octave == rhs.octave &&
               lhs.duration == rhs.duration &&
               lhs.timeModification == rhs.timeModification &&
               lhs.isRest == rhs.isRest &&
               lhs.isDotted == rhs.isDotted
    }
}

// Enums
extension Note {
    enum Pitch: String, CaseIterable {
        case C, D, E, F, G, A, B
        
        func distanceFromC() -> Int {
            switch self {
            case .C: return 0
            case .D: return 1
            case .E: return 2
            case .F: return 3
            case .G: return 4
            case .A: return 5
            case .B: return 6
            }
        }
        
        func semitonesFromC() -> Int {
            switch self {
            case .C: return 0
            case .D: return 2
            case .E: return 4
            case .F: return 5
            case .G: return 7
            case .A: return 9
            case .B: return 11
            }
        }
    }
    
    enum Accidental: Int {
        case Sharp = 1
        case Flat = -1
        case Natural = 0
        case DoubleSharp = 2
        case DoubleFlat = -2
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
        
        var next: Octave? {
            Octave(rawValue: self.rawValue + 1)
        }

        var prev: Octave? {
            Octave(rawValue: self.rawValue - 1)
        }
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
        
        var isHollow: Bool {
            switch self {
            case .breve:
                return true
            case .whole:
                return true
            case .half:
                return true
            default:
                return false
            }
        }
    }
    
    enum TimeModification: Equatable {
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
    
    enum OctaveShift {
        case above
        case below
    }
}

extension Note {
    mutating func increaseOctave() {
        if let nextOctave = octave?.next {
            octave = nextOctave
            octaveShift = .below
        }
    }

    mutating func decreaseOctave() {
        if let prevOctave = octave?.prev {
            octave = prevOctave
            octaveShift = .above
        }
    }
}

extension Note {
    func calculateDistance(from note1: Note, to note2: Note) -> Int {
        guard let pitch1 = note1.pitch, let pitch2 = note2.pitch else {
            return 0 // Handle the case where pitch is not set
        }
        
        let octaveDistance = (note2.octave?.rawValue ?? 0) - (note1.octave?.rawValue ?? 0)
        let pitchDistance = pitch2.distanceFromC() - pitch1.distanceFromC()
        
        return octaveDistance * 7 + pitchDistance
    }
}

extension Note: CustomStringConvertible {
    var description: String {
        var description = "Note: "
        description += "\(pitch?.rawValue ?? "")\(accidental?.rawValue ?? 0)\(octave?.rawValue.description ?? "")"
        description += " D: \(duration) Dot: \(isDotted) Rest: \(isRest) Accent: \(hasAccent) Tie: \(String(describing: tie)) TMod: \(String(describing: timeModification))\n"
        return description
    }
}

//
//  NoteModel.swift
//  Intervision
//
//  Created by Reuben on 06/02/2024.
//

import Foundation

class Note: Identifiable, Equatable {
    
    init(
        pitch: Pitch? = nil,
        accidental: Accidental? = nil,
        octave: Octave? = nil,
        octaveShift: OctaveShift? = nil,
        duration: Duration,
        timeModification: TimeModification? = nil,
        changeDynamic: ChangeDynamic? = nil,
        tie: Tie? = nil,
        slur: Slur? = nil,
        isRest: Bool,
        isDotted: Bool,
        hasAccent: Bool,
        id: UUID = UUID()
    ) {
        self.pitch = pitch
        self.accidental = accidental
        self.octave = octave
        self.octaveShift = octaveShift
        self.duration = duration
        self.timeModification = timeModification
        self.changeDynamic = changeDynamic
        self.tie = tie
        self.slur = slur
        self.isRest = isRest
        self.isDotted = isDotted
        self.hasAccent = hasAccent
        self.id = id
    }
    
    var pitch: Pitch?
    var accidental: Accidental?
    var octave: Octave?
    var octaveShift: OctaveShift?
    var duration: Duration
    var timeModification: TimeModification?
    var changeDynamic: ChangeDynamic?
    var tie: Tie?
    var slur: Slur?
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
        
        var nextPitch: Note.Pitch {
            let allPitches = Note.Pitch.allCases
            guard let currentIndex = allPitches.firstIndex(of: self) else { return self }
            let nextIndex = (currentIndex + 1) % allPitches.count
            return allPitches[nextIndex]
        }
        
        var previousPitch: Note.Pitch {
            let allPitches = Note.Pitch.allCases
            guard let currentIndex = allPitches.firstIndex(of: self) else { return self }
            let previousIndex = (currentIndex + allPitches.count - 1) % allPitches.count
            return allPitches[previousIndex]
        }
        
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
    
    enum Duration: Double, CaseIterable {
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
        case custom(actual: Int, normal: Int, normalDuration: Duration)
    }
    
    enum ChangeDynamic {
        case Crescendo
        case Decrescendo
        case Stop
    }

    
    enum Tie {
        case Start
        case Stop
        case Both
    }
    
    enum Slur {
        case Start
        case Stop
    }
    
    enum OctaveShift {
        case above
        case below
    }
}

extension Note {
    func increaseOctave(applyOctaveShift: Bool = true) {
        if let nextOctave = octave?.next {
            octave = nextOctave
            
            if applyOctaveShift {
                octaveShift = .below
            }
        }
    }

    func decreaseOctave(applyOctaveShift: Bool = true) {
        if let prevOctave = octave?.prev {
            octave = prevOctave
            
            if applyOctaveShift {
                octaveShift = .above
            }
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

extension Note {
    func increaseSemitone(sharps: Bool) {
        guard let currentPitch = self.pitch else { return }
        
        var currentSemitonesFromC = currentPitch.semitonesFromC()
        
        if let currentAccidental = self.accidental {
            currentSemitonesFromC += currentAccidental.rawValue
        }
        
        switch currentSemitonesFromC {
        case -2:
            self.pitch = .B
            self.accidental = nil
            self.decreaseOctave()
        case -1:
            self.pitch = .C
            self.accidental = nil
        case 0:
            self.pitch = sharps ? .C : .D
            self.accidental = sharps ? .Sharp : .Flat
        case 1:
            self.pitch = .D
            self.accidental = nil
        case 2:
            self.pitch = sharps ? .D : .E
            self.accidental = sharps ? .Sharp : .Flat
        case 3:
            self.pitch = .E
            self.accidental = nil
        case 4:
            self.pitch = .F
            self.accidental = nil
        case 5:
            self.pitch = sharps ? .F : .G
            self.accidental = sharps ? .Sharp : .Flat
        case 6:
            self.pitch = .G
            self.accidental = nil
        case 7:
            self.pitch = sharps ? .G : .A
            self.accidental = sharps ? .Sharp : .Flat
        case 8:
            self.pitch = .A
            self.accidental = nil
        case 9:
            self.pitch = sharps ? .A : .B
            self.accidental = sharps ? .Sharp : .Flat
        case 10:
            self.pitch = .B
            self.accidental = nil
        case 11:
            self.pitch = .C
            self.accidental = nil
            self.increaseOctave()
        case 12:
            self.pitch = sharps ? .C : .D
            self.accidental = sharps ? .Sharp : .Flat
            self.increaseOctave()
        case 13:
            self.pitch = .D
            self.accidental = nil
            self.increaseOctave()
        default:
            return
        }
    }
    
    func decreaseSemitone(sharps: Bool) {
        guard let currentPitch = self.pitch else { return }
        
        var currentSemitonesFromC = currentPitch.semitonesFromC()
        
        if let currentAccidental = self.accidental {
            currentSemitonesFromC += currentAccidental.rawValue
        }
        
        switch currentSemitonesFromC {
        case -2:
            self.pitch = .A
            self.accidental = nil
            self.decreaseOctave()
        case -1:
            self.pitch = sharps ? .A : .B
            self.accidental = sharps ? .Sharp : .Flat
            self.decreaseOctave()
        case 0:
            self.pitch = .B
            self.accidental = nil
            self.decreaseOctave()
        case 1:
            self.pitch = .C
            self.accidental = nil
        case 2:
            self.pitch = sharps ? .C : .D
            self.accidental = sharps ? .Sharp : .Flat
        case 3:
            self.pitch = .D
            self.accidental = nil
        case 4:
            self.pitch = sharps ? .D : .E
            self.accidental = sharps ? .Sharp : .Flat
        case 5:
            self.pitch = .E
            self.accidental = nil
        case 6:
            self.pitch = .F
            self.accidental = nil
        case 7:
            self.pitch = sharps ? .F : .G
            self.accidental = sharps ? .Sharp : .Flat
        case 8:
            self.pitch = .G
            self.accidental = nil
        case 9:
            self.pitch = sharps ? .G : .A
            self.accidental = sharps ? .Sharp : .Flat
        case 10:
            self.pitch = .A
            self.accidental = nil
        case 11:
            self.pitch = sharps ? .A : .B
            self.accidental = sharps ? .Sharp : .Flat
        case 12:
            self.pitch = .B
            self.accidental = nil
        case 13:
            self.pitch = .C
            self.accidental = nil
            self.increaseOctave()
        default:
            return
        }
    }
}

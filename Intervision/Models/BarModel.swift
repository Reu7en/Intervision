//
//  BarModel.swift
//  Intervision
//
//  Created by Reuben on 06/02/2024.
//

import Foundation

struct Bar: Identifiable, Equatable {
    var chords: [Chord]
    var tempo: Int
    var timeSignature: TimeSignature
    var keySignature: KeySignature
    
    // Identifiable
    var id = UUID()
    
    // Equatable
    static func == (lhs: Bar, rhs: Bar) -> Bool {
        lhs.id == rhs.id
    }
}

// Enums
extension Bar {
    enum Tempo {
        case common(bpm: Int)
        case cut(bpm: Int)
    }
    
    enum TimeSignature {
        case common
        case cut
        case threeFour
        case sixEight
        case custom(beats: Int, noteValue: Int)
    }
    
    enum KeySignature: String {
        // Major keys
        case CMajor = "C Major"
        case GMajor = "G Major"
        case DMajor = "D Major"
        case AMajor = "A Major"
        case EMajor = "E Major"
        case BMajor = "B Major"
        case FSharpMajor = "F# Major"
        case CSharpMajor = "C# Major"
        case FMajor = "F Major"
        case BFlatMajor = "B♭ Major"
        case EFlatMajor = "E♭ Major"
        case AFlatMajor = "A♭ Major"
        case DFlatMajor = "D♭ Major"
        case GFlatMajor = "G♭ Major"
        case CFlatMajor = "C♭ Major"
        
        // Minor keys
        case AMinor = "A Minor"
        case EMinor = "E Minor"
        case BMinor = "B Minor"
        case FSharpMinor = "F# Minor"
        case CSharpMinor = "C# Minor"
        case GSharpMinor = "G# Minor"
        case DSharpMinor = "D# Minor"
        case ASharpMinor = "A# Minor"
        case DMinor = "D Minor"
        case GMinor = "G Minor"
        case CMinor = "C Minor"
        case FMinor = "F Minor"
        case BFlatMinor = "B♭ Minor"
        case EFlatMinor = "E♭ Minor"
        case AFlatMinor = "A♭ Minor"
        
        var alteredNotes: [(Note.Pitch, Note.Accidental)] {
            switch self {
            // Sharps
            case .CMajor, .AMinor:
                return []
            case .GMajor, .EMinor:
                return [(.F, .Sharp)]
            case .DMajor, .BMinor:
                return [(.F, .Sharp), (.C, .Sharp)]
            case .AMajor, .FSharpMinor:
                return [(.F, .Sharp), (.C, .Sharp), (.G, .Sharp)]
            case .EMajor, .CSharpMinor:
                return [(.F, .Sharp), (.C, .Sharp), (.G, .Sharp), (.D, .Sharp)]
            case .BMajor, .GSharpMinor:
                return [(.F, .Sharp), (.C, .Sharp), (.G, .Sharp), (.D, .Sharp), (.A, .Sharp)]
            case .FSharpMajor, .DSharpMinor:
                return [(.F, .Sharp), (.C, .Sharp), (.G, .Sharp), (.D, .Sharp), (.A, .Sharp), (.E, .Sharp)]
            case .CSharpMajor, .ASharpMinor:
                return [(.F, .Sharp), (.C, .Sharp), (.G, .Sharp), (.D, .Sharp), (.A, .Sharp), (.E, .Sharp), (.B, .Sharp)]
            // Flats
            case .FMajor, .DMinor:
                return [(.B, .Flat)]
            case .BFlatMajor, .GMinor:
                return [(.B, .Flat), (.E, .Flat)]
            case .EFlatMajor, .CMinor:
                return [(.B, .Flat), (.E, .Flat), (.A, .Flat)]
            case .AFlatMajor, .FMinor:
                return [(.B, .Flat), (.E, .Flat), (.A, .Flat), (.D, .Flat)]
            case .DFlatMajor, .BFlatMinor:
                return [(.B, .Flat), (.E, .Flat), (.A, .Flat), (.D, .Flat), (.G, .Flat)]
            case .GFlatMajor, .EFlatMinor:
                return [(.B, .Flat), (.E, .Flat), (.A, .Flat), (.D, .Flat), (.G, .Flat), (.C, .Flat)]
            case .CFlatMajor, .AFlatMinor:
                return [(.B, .Flat), (.E, .Flat), (.A, .Flat), (.D, .Flat), (.G, .Flat), (.C, .Flat), (.F, .Flat)]
            }
        }
    }
}

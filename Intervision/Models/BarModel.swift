//
//  BarModel.swift
//  Intervision
//
//  Created by Reuben on 06/02/2024.
//

import Foundation

struct Bar: Identifiable, Equatable {
    var chords: [Chord]
    var tempo: Tempo?
    var clef: Clef
    var timeSignature: TimeSignature
    var `repeat`: Repeat?
    var doubleLine: Bool
    var volta: Int?
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
        case half(bpm: Int)
        case quarter(bpm: Int)
        case eighth(bpm: Int)
    }
    
    enum Clef {
        case Treble, Soprano, Alto, Tenor, Bass, Neutral
    }
    
    enum TimeSignature {
        case common
        case cut
        case custom(beats: Int, noteValue: Int)
    }
    
    enum Repeat {
        case RepeatStart
        case RepeatEnd
    }
    
    enum KeySignature {
        // Major keys
        case CMajor
        case GMajor
        case DMajor
        case AMajor
        case EMajor
        case BMajor
        case FSharpMajor
        case CSharpMajor
        case FMajor
        case BFlatMajor
        case EFlatMajor
        case AFlatMajor
        case DFlatMajor
        case GFlatMajor
        case CFlatMajor
        
        // Minor keys
        case AMinor
        case EMinor
        case BMinor
        case FSharpMinor
        case CSharpMinor
        case GSharpMinor
        case DSharpMinor
        case ASharpMinor
        case DMinor
        case GMinor
        case CMinor
        case FMinor
        case BFlatMinor
        case EFlatMinor
        case AFlatMinor
        
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
        
        var sharps: Bool {
            switch self {
            // Sharps
            case .CMajor, .AMinor:
                return true
            case .GMajor, .EMinor:
                return true
            case .DMajor, .BMinor:
                return true
            case .AMajor, .FSharpMinor:
                return true
            case .EMajor, .CSharpMinor:
                return true
            case .BMajor, .GSharpMinor:
                return true
            case .FSharpMajor, .DSharpMinor:
                return true
            case .CSharpMajor, .ASharpMinor:
                return true
                
            // Flats
            case .FMajor, .DMinor:
                return false
            case .BFlatMajor, .GMinor:
                return false
            case .EFlatMajor, .CMinor:
                return false
            case .AFlatMajor, .FMinor:
                return false
            case .DFlatMajor, .BFlatMinor:
                return false
            case .GFlatMajor, .EFlatMinor:
                return false
            case .CFlatMajor, .AFlatMinor:
                return false
            }
        }
    }
}

extension Bar: CustomStringConvertible {
    var description: String {
        var description = "\nBar: "
        description += "Key: \(keySignature)\n"
        description += "Clef: \(clef)\n"
        description += "Tempo: \(String(describing: tempo))\n"
        description += "Time: \(String(describing: timeSignature))\n"
        description += "Repeat: \(String(describing: `repeat`))\n"
        description += "Volta: \(volta?.description ?? "")\n"
        description += "Section End: \(doubleLine)\n"
        description += "Chords: \(chords.map { $0.notes.description }.joined(separator: ", "))"
        return description
    }
}

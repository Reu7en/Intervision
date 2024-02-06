//
//  ScoreModel.swift
//  Intervision
//
//  Created by Reuben on 06/02/2024.
//

import Foundation

struct Score: Identifiable, Equatable {
    var bars: [Bar]
    var tempo: Int
    var keySignature: KeySignature
    
    // Identifiable
    var id = UUID()
    
    // Equatable
    static func == (lhs: Score, rhs: Score) -> Bool {
        lhs.id == rhs.id
    }
}

// Enums
extension Score {
    enum Tempo {
        case common(bpm: Int)
        case cut(bpm: Int)
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
        
        var alteredNotes: [Note.Pitch] {
            switch self {
            // Sharps
            case .CMajor, .AMinor:
                return []
            case .GMajor, .EMinor:
                return [.FSharp]
            case .DMajor, .BMinor:
                return [.FSharp, .CSharp]
            case .AMajor, .FSharpMinor:
                return [.FSharp, .CSharp, .GSharp]
            case .EMajor, .CSharpMinor:
                return [.FSharp, .CSharp, .GSharp, .DSharp]
            case .BMajor, .GSharpMinor:
                return [.FSharp, .CSharp, .GSharp, .DSharp, .ASharp]
            case .FSharpMajor, .DSharpMinor:
                return [.FSharp, .CSharp, .GSharp, .DSharp, .ASharp, .ESharp]
            case .CSharpMajor, .ASharpMinor:
                return [.FSharp, .CSharp, .GSharp, .DSharp, .ASharp, .ESharp, .BSharp]
            // Flats
            case .FMajor, .DMinor:
                return [.BFlat]
            case .BFlatMajor, .GMinor:
                return [.BFlat, .EFlat]
            case .EFlatMajor, .CMinor:
                return [.BFlat, .EFlat, .AFlat]
            case .AFlatMajor, .FMinor:
                return [.BFlat, .EFlat, .AFlat, .DFlat]
            case .DFlatMajor, .BFlatMinor:
                return [.BFlat, .EFlat, .AFlat, .DFlat, .GFlat]
            case .GFlatMajor, .EFlatMinor:
                return [.BFlat, .EFlat, .AFlat, .DFlat, .GFlat, .CFlat]
            case .CFlatMajor, .AFlatMinor:
                return [.BFlat, .EFlat, .AFlat, .DFlat, .GFlat, .CFlat, .FFlat]
            }
        }
    }
}

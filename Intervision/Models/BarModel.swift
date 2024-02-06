//
//  BarModel.swift
//  Intervision
//
//  Created by Reuben on 06/02/2024.
//

import Foundation

struct Bar: Identifiable, Equatable {
    var chords: [Chord]
    var timeSignature: TimeSignature
    
    // Identifiable
    var id = UUID()
    
    // Equatable
    static func == (lhs: Bar, rhs: Bar) -> Bool {
        lhs.id == rhs.id
    }
}

// Enums
enum TimeSignature {
    case common
    case cut
    case threeFour
    case sixEight
    case custom(beats: Int, noteValue: Int)
}

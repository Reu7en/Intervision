//
//  ChordModel.swift
//  Intervision
//
//  Created by Reuben on 06/02/2024.
//

import Foundation

struct Chord: Identifiable, Equatable {
    var notes: [Note]
    
    // Identifiable
    var id = UUID()
    
    // Equatable
    static func == (lhs: Chord, rhs: Chord) -> Bool {
        lhs.id == rhs.id
    }
}

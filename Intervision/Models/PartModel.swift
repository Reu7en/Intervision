//
//  PartModel.swift
//  Intervision
//
//  Created by Reuben on 08/02/2024.
//

import Foundation

struct Part: Identifiable, Equatable {
    var staff: Staff
    var bars: [[Bar]]
    
    // Identifiable
    var id = UUID()
    
    // Equatable
    static func == (lhs: Part, rhs: Part) -> Bool {
        lhs.id == rhs.id
    }
}

// Enums
extension Part {
    enum Staff {
        case Treble, Bass, Grand, Neutral
    }
}

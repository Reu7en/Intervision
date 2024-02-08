//
//  GraceModel.swift
//  Intervision
//
//  Created by Reuben on 08/02/2024.
//

import Foundation

struct Grace: Identifiable, Equatable {
    var note: Note
    var style: Style
    
    // Identifiable
    var id = UUID()
    
    // Equatable
    static func == (lhs: Grace, rhs: Grace) -> Bool {
        lhs.id == rhs.id
    }
}

// Enums
extension Grace {
    enum Style {
        case Acciaccatura
        case Appoggiatura
    }
}

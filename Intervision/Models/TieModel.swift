//
//  TieModel.swift
//  Intervision
//
//  Created by Reuben on 08/02/2024.
//

import Foundation

struct Tie: Identifiable, Equatable {
    var startNote: Note
    var endNote: Note
    
    // Identifiable
    var id = UUID()
    
    // Equatable
    static func == (lhs: Tie, rhs: Tie) -> Bool {
        lhs.id == rhs.id
    }
}

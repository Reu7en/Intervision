//
//  StaveModel.swift
//  Intervision
//
//  Created by Reuben on 08/02/2024.
//

import Foundation

struct Stave: Identifiable, Equatable {
    var rows: [Row]
    
    // Identifiable
    var id = UUID()
    
    // Equatable
    static func == (lhs: Stave, rhs: Stave) -> Bool {
        lhs.id == rhs.id
    }
    
    init(rowCount: Int) {
        self.rows = (0..<rowCount).map { _ in Row(isActive: true) }
    }
    
    init(rowCount: Int, inactiveRows: Int...) {
        self.rows = (0..<rowCount).map { Row(isActive: !inactiveRows.contains($0)) }
    }
}

// Row Struct
extension Stave {
    struct Row: Identifiable, Equatable {
        var isActive: Bool
        
        // Identifiable
        var id = UUID()
        
        // Equatable
        static func == (lhs: Row, rhs: Row) -> Bool {
            lhs.id == rhs.id
        }
    }
}

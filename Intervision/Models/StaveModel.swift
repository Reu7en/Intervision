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
        self.rows = [Row]()
        
        for _ in 0..<rowCount {
            self.rows.append(Row(isActive: true))
        }
    }
    
    init(rowCount: Int, inactiveRows: Int...) {
        self.rows = [Row]()
        
        for i in 0..<rowCount {
            self.rows.append(Row(isActive: !inactiveRows.contains(i)))
        }
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

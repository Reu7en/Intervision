//
//  PartModel.swift
//  Intervision
//
//  Created by Reuben on 08/02/2024.
//

import Foundation

class Part: Identifiable, Equatable {
    var name: String?
    var bars: [[Bar]]
    
    // Identifiable
    var id = UUID()
    
    // Equatable
    static func == (lhs: Part, rhs: Part) -> Bool {
        lhs.id == rhs.id
    }
    
    init(
        name: String? = nil,
        bars: [[Bar]],
        id: UUID = UUID()
    ) {
        self.name = name
        self.bars = bars
        self.id = id
    }
}

extension Part: CustomStringConvertible {
    var description: String {
        var description = "Part: "
        description += "\(name ?? "")"
        
        for bar in bars {
            description += "\(bar)\n"
        }
        
        return description
    }
}

//
//  ScoreModel.swift
//  Intervision
//
//  Created by Reuben on 06/02/2024.
//

import Foundation

class Score: Identifiable, Equatable {
    
    init(title: String? = nil, composer: String? = nil, parts: [Part]? = nil, id: UUID = UUID()) {
        self.title = title
        self.composer = composer
        self.parts = parts
        self.id = id
    }
    
    var title: String?
    var composer: String?
    var parts: [Part]?
    
    // Identifiable
    var id = UUID()
    
    // Equatable
    static func == (lhs: Score, rhs: Score) -> Bool {
        lhs.id == rhs.id
    }
}

extension Score: CustomStringConvertible {
    var description: String {
        var description = "Score: "
        description += "\(title ?? "")\n"
        description += "\(composer ?? "")\n"
        
        if let p = parts {
            for part in p {
                description += "\(part.description)\n"
            }
        }
        
        return description
    }
}

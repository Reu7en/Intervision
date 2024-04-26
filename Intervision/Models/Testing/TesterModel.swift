//
//  TesterModel.swift
//  Intervision
//
//  Created by Reuben on 26/04/2024.
//

import Foundation

struct Tester: Identifiable {
    let skills: [(Skill, SkillLevel)]
    
    // Identifiable
    let id: UUID
    
    init(
        skills: [(Skill, SkillLevel)],
        id: UUID
    ) {
        self.skills = skills
        self.id = id
    }
}

extension Tester {
    enum Skill {
        case Performer
        case Composer
        case Theorist
        case Educator
        case Developer
    }
    
    enum SkillLevel: CaseIterable {
        case None
        case Beginner
        case Intermediate
        case Advanced
    }
}

//
//  TesterModel.swift
//  Intervision
//
//  Created by Reuben on 26/04/2024.
//

import Foundation

struct Tester: Identifiable, Codable {
    let skills: [Skill]
    let id: UUID

    init(skills: [Skill], id: UUID) {
        self.skills = skills
        self.id = id
    }
}

struct Skill: Codable {
    let type: SkillType
    let level: SkillLevel
    
    enum SkillType: String, Codable {
        case Performer
        case Composer
        case Theorist
        case Educator
        case Developer
    }

    enum SkillLevel: String, Codable, CaseIterable {
        case None
        case Beginner
        case Intermediate
        case Advanced
    }
}

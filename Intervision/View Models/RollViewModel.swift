//
//  RollViewModel.swift
//  Intervision
//
//  Created by Reuben on 24/02/2024.
//

import Foundation
import SwiftUI

class RollViewModel: ObservableObject {
    
    @Published var score: Score?
    @Published var parts: [Part]?
    
    init(score: Score?) {
        self.score = score
    }
    
    func addAllParts() {
        guard let score = score, let parts = score.parts else { return }
        self.parts = parts
    }

    func removeAllParts() {
        self.parts = nil
    }

    func addPart(_ part: Part) {
        var updatedParts = self.parts ?? []
        updatedParts.append(part)
        self.parts = sortPartsBasedOnScoreOrder(updatedParts)
    }

    func removePart(_ part: Part) {
        guard var updatedParts = self.parts else { return }
        updatedParts.removeAll { $0.id == part.id }
        self.parts = sortPartsBasedOnScoreOrder(updatedParts)
    }
    
    func sortPartsBasedOnScoreOrder(_ parts: [Part]) -> [Part] {
        guard let scoreParts = score?.parts else { return parts }
        
        var sortedParts = [Part]()
        for scorePart in scoreParts {
            if let matchingPart = parts.first(where: { $0.id == scorePart.id }) {
                sortedParts.append(matchingPart)
            }
        }
        
        return sortedParts
    }
    
    static func getBeatData(bar: Bar) -> (beats: Int, noteValue: Int) {
        switch bar.timeSignature {
        case .common:
            return (4, 4)
        case .cut:
            return (2, 2)
        case .custom(let beats, let noteValue):
            return (beats, noteValue)
        }
    }
}

extension RollViewModel {
    enum IntervalLinesType: String, Identifiable, CaseIterable {
        case none
        case staves
        case parts
        case all
        
        var id: UUID {
            UUID()
        }
    }
}

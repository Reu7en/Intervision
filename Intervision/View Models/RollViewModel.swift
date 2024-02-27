//
//  RollViewModel.swift
//  Intervision
//
//  Created by Reuben on 24/02/2024.
//

import Foundation

class RollViewModel: ObservableObject {
    
    @Published var score: Score?
    @Published var parts: [Part]?
    
    init(score: Score?) {
        self.score = score
    }
    
    func setAllParts() {
        if let score = score,
           let parts = score.parts {
            self.parts = parts
        }
    }
    
    func setPart(partIndex: Int) {
        if let score = score,
           let parts = score.parts {
            if partIndex < parts.count {
                self.parts = [parts[partIndex]]
            }
        }
    }
    
    static func getBeats(bar: Bar) -> Int {
        switch bar.timeSignature {
        case .common:
            return 4
        case .cut:
            return 2
        case .custom(let beats, let noteValue):
            return beats
        }
    }
}

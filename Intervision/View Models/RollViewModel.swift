//
//  RollViewModel.swift
//  Intervision
//
//  Created by Reuben on 24/02/2024.
//

import Foundation

class RollViewModel: ObservableObject {
    
    @Published var score: Score?
    @Published var part: Part?
    
    init(score: Score?) {
        self.score = score
    }
    
    func setPart(partIndex: Int) {
        if let score = score,
           let parts = score.parts {
            if partIndex < parts.count {
                self.part = parts[partIndex]
            }
        }
    }
}

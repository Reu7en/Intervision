//
//  ScoreManager.swift
//  Intervision
//
//  Created by Reuben on 12/03/2024.
//

import Foundation

class ScoreManager: ObservableObject {
    @Published var score: Score?
    
    func updateScore(newScore: Score?) {
        DispatchQueue.main.async {
            self.score = newScore
        }
    }
}

//
//  ScoreViewModel.swift
//  Intervision
//
//  Created by Reuben on 09/02/2024.
//

import Foundation
import SwiftUI

class ScoreViewModel: ObservableObject {
    
    @ObservedObject var scoreManager: ScoreManager
    
    @Published var viewType: ViewType
    
    init(scoreManager: ScoreManager, viewType: ViewType = .Horizontal) {
        self.scoreManager = scoreManager
        self.viewType = viewType
    }
}

extension ScoreViewModel {
    enum ViewType {
        case Horizontal
        case Vertical
        case VerticalWide
    }
}

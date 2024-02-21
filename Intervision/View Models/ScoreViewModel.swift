//
//  ScoreViewModel.swift
//  Intervision
//
//  Created by Reuben on 09/02/2024.
//

import Foundation

class ScoreViewModel: ObservableObject {
    
    @Published var viewType: ViewType
    @Published var score: Score?
    
    init(viewType: ViewType = .Horizontal, score: Score?) {
        self.viewType = viewType
        self.score = score
    }
}

extension ScoreViewModel {
    enum ViewType {
        case Horizontal
        case Vertical
        case VerticalWide
    }
}

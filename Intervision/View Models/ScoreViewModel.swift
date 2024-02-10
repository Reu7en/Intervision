//
//  ScoreViewModel.swift
//  Intervision
//
//  Created by Reuben on 09/02/2024.
//

import Foundation

class ScoreViewModel: ObservableObject {
    @Published var viewType: ViewType
    
    init() {
        self.viewType = .Horizontal
    }
}

extension ScoreViewModel {
    enum ViewType {
        case Horizontal
        case Vertical
        case VerticalWide
    }
}

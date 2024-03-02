//
//  IntervalLinesViewModel.swift
//  Intervision
//
//  Created by Reuben on 01/03/2024.
//

import Foundation
import SwiftUI

class IntervalLinesViewModel: ObservableObject {
    
    @Published var harmonicLines: [([CGPoint], Color)]?
    @Published var melodicLines: [([CGPoint], Color)]?
    
    let segments: [[[[Segment]]]]
    
    init(segments: [[[[Segment]]]], intervalLinesType: IntervalLinesType, barIndex: Int) {
        self.segments = segments
        
        switch intervalLinesType {
        case .none:
            break
        case .staves:
            break
        case .parts:
            break
        case .all:
            break
        }
    }
    
    func getStaveSegments() {
        
    }
    
    func getPartSegments() {
        
    }
    
    func getAllSegments() {
        
    }
}

extension IntervalLinesViewModel {
    enum IntervalLinesType: String, CaseIterable {
        case none
        case staves
        case parts
        case all
    }
}

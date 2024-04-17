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
    
    static let pageAspectRatio: CGFloat = 210 / 297
    
    let maximumChordsPerWidth: Int
    let maximumBarsPerWidth: Int
    let maximumStavesPerPage: Int
    
    var pages: [[[(Bar, Int, Bool, Bool, Bool, Bool, String)]]]? {
        calculatePages()
    }
    
    init
    (
        scoreManager: ScoreManager,
        viewType: ViewType = .Horizontal,
        maximumChordsPerWidth: Int = 16,
        maximumBarsPerWidth: Int = 4,
        maximumStavesPerPage: Int = 10
    ) {
        self.scoreManager = scoreManager
        self.viewType = viewType
        self.maximumChordsPerWidth = maximumChordsPerWidth
        self.maximumBarsPerWidth = maximumBarsPerWidth
        self.maximumStavesPerPage = maximumStavesPerPage
    }
    
    private func calculatePages() -> [[[(Bar, Int, Bool, Bool, Bool, Bool, String)]]]? {
        guard let score = self.scoreManager.score,
              let parts = score.parts else { return nil }
        
        var staveCount = 0
        
        for part in parts {
            if let bars = part.bars.first {
                staveCount += bars.count
            }
        }
        
        let stavesPerPage = max(maximumStavesPerPage, staveCount)
        
        var maximumBarIndex = 0
        
        for part in parts {
            if maximumBarIndex == 0 {
                maximumBarIndex = part.bars.count
            }
            
            if part.bars.count != maximumBarIndex {
                return nil
            }
        }
        
        var pages: [[[(Bar, Int, Bool, Bool, Bool, Bool, String)]]] = []
        var currentPage: [[(Bar, Int, Bool, Bool, Bool, Bool, String)]] = []
        var currentLines: [[(Bar, Int, Bool, Bool, Bool, Bool, String)]] = Array(repeating: [], count: staveCount)
        
        var currentChordsPerWidth = 0
        var currentBarsPerWidth = 0
        var currentStavesPerPage = 0
        
        for currentBarIndex in 0..<maximumBarIndex {
            var maximumChordCount = 0
            
            for part in parts {
                for bar in part.bars[currentBarIndex] {
                    maximumChordCount = max(maximumChordCount, bar.chords.count)
                }
            }
            
            if currentStavesPerPage + staveCount > stavesPerPage {
                pages.append(currentPage)
                currentPage = []
                currentStavesPerPage = 0
            }
            
            if currentChordsPerWidth + maximumChordCount > self.maximumChordsPerWidth || currentBarsPerWidth == maximumBarsPerWidth {
                for line in currentLines {
                    currentPage.append(line)
                    currentLines = Array(repeating: [], count: staveCount)
                }
                
                currentStavesPerPage += staveCount
                currentChordsPerWidth = 0
                currentBarsPerWidth = 0
            }
            
            var currentStaveIndex = 0
            
            for part in parts {
                for bar in part.bars[currentBarIndex] {
                    let barNumber = (currentLines[currentStaveIndex].isEmpty && currentStaveIndex == 0) ? currentBarIndex + 1 : -1
                    let shouldShowLeadingInformation = currentLines[currentStaveIndex].isEmpty
                    let shouldShowClef = currentBarIndex == 0 ? false : part.bars[currentBarIndex].first?.clef != part.bars[currentBarIndex - 1].first?.clef
                    let shouldShowKey = currentBarIndex == 0 ? false : part.bars[currentBarIndex].first?.keySignature != part.bars[currentBarIndex - 1].first?.keySignature
                    let shouldShowTime = currentBarIndex == 0 ? false : part.bars[currentBarIndex].first?.timeSignature != part.bars[currentBarIndex - 1].first?.timeSignature
                    
                    currentLines[currentStaveIndex].append(
                        (
                            bar,
                            barNumber,
                            shouldShowLeadingInformation || shouldShowClef,
                            shouldShowLeadingInformation || shouldShowKey,
                            shouldShowLeadingInformation || shouldShowTime,
                            shouldShowLeadingInformation,
                            part.name ?? ""
                        )
                    )
                    
                    currentStaveIndex += 1
                }
            }
            
            currentChordsPerWidth += maximumChordCount
            currentBarsPerWidth += 1
        }
        
        return pages
    }
}

extension ScoreViewModel {
    enum ViewType {
        case Horizontal
        case Vertical
        case VerticalWide
    }
}

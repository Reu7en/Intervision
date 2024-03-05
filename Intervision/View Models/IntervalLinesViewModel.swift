//
//  IntervalLinesViewModel.swift
//  Intervision
//
//  Created by Reuben on 01/03/2024.
//

import Foundation
import SwiftUI

class IntervalLinesViewModel: ObservableObject {
    
    @Published var harmonicLines: [Line]?
    @Published var melodicLines: [([CGPoint], Color)]?
    
    let segments: [[[[Segment]]]]
    let barIndex: Int
    let barWidth: CGFloat
    let rowHeight: CGFloat
    
    init(segments: [[[[Segment]]]], harmonicIntervalLinesType: IntervalLinesType, melodicIntervalLinesType: IntervalLinesType, barIndex: Int, barWidth: CGFloat, rowHeight: CGFloat) {
        self.segments = segments
        self.barIndex = barIndex
        self.barWidth = barWidth
        self.rowHeight = rowHeight
        
        var harmonicSegments: [[Segment]]?
        
        switch harmonicIntervalLinesType {
        case .none:
            break
        case .staves:
            harmonicSegments = getStaveSegments()
            break
        case .parts:
            harmonicSegments = getPartSegments()
            break
        case .all:
            harmonicSegments = getAllSegments()
            break
        }
        
        if let harmonicSegments = harmonicSegments {
            self.harmonicLines = calculateHarmonicLines(segments: harmonicSegments)
        }
        
        var melodicSegments: [[Segment]]?
        
        switch melodicIntervalLinesType {
        case .none:
            break
        case .staves:
            melodicSegments = getStaveSegments()
            break
        case .parts:
            melodicSegments = getPartSegments()
            break
        case .all:
            melodicSegments = getAllSegments()
            break
        }
        
        if let melodicSegments = melodicSegments {
            self.melodicLines = calculateMelodicLines(segments: melodicSegments)
        }
        
    }
    
    func getStaveSegments() -> [[Segment]]? {
        guard segments.indices.contains(0), segments[0].indices.contains(barIndex) else { return nil }
        
        var staveSegments: [[Segment]] = []
        
        for part in segments {
            let bar = part[barIndex]
            
            for stave in bar {
                staveSegments.append(stave)
            }
        }
        
        return staveSegments
    }
    
    func getPartSegments() -> [[Segment]]? {
        guard segments.indices.contains(0), segments[0].indices.contains(barIndex) else { return nil }
        
        var partSegments: [[Segment]] = []
        
        for part in segments {
            let bar = part[barIndex]
            
            var flatSegments: [Segment] = []
            
            for stave in bar {
                for segment in stave {
                    flatSegments.append(segment)
                }
            }
            
            partSegments.append(flatSegments)
        }
        
        return partSegments
    }
    
    func getAllSegments() -> [[Segment]]? {
        guard segments.indices.contains(0), segments[0].indices.contains(barIndex) else { return nil }
        
        var allSegments: [[Segment]] = []
        var flatSegments: [Segment] = []
        
        for part in segments {
            let bar = part[barIndex]
            
            for stave in bar {
                for segment in stave {
                    flatSegments.append(segment)
                }
            }
            
            allSegments.append(flatSegments)
        }
        
        return allSegments
    }
    
    func calculateHarmonicLines(segments: [[Segment]]) -> [Line] {
        var lines: [Line] = []
        
        for segmentGroup in segments {
            if !segmentGroup.isEmpty {
                for i in 0..<(segmentGroup.count - 1) {
                    for j in (i + 1)..<segmentGroup.count {
                        let segment1 = segmentGroup[i]
                        let segment2 = segmentGroup[j]
                        
                        if segmentsAreHarmonic(segment1, segment2) {
                            let xPosition = barWidth * max(CGFloat(segment1.durationPreceeding), CGFloat(segment2.durationPreceeding))
                            let yStartPosition = rowHeight * CGFloat(segment1.rowIndex) + rowHeight / 2
                            let yEndPosition = rowHeight * CGFloat(segment2.rowIndex) + rowHeight / 2
                            
                            let startPoint = CGPoint(x: xPosition, y: yStartPosition)
                            let endPoint = CGPoint(x: xPosition, y: yEndPosition)
                            
                            let intervalColorIndex = (abs(segment1.rowIndex - segment2.rowIndex) - 1) % 12
                            let color = RollViewModel.harmonicIntervalLineColors.indices.contains(intervalColorIndex) ? RollViewModel.harmonicIntervalLineColors[intervalColorIndex] : Color.clear
                            
                            let line = Line(startPoint: startPoint, endPoint: endPoint, color: color)
                            
                            if !lines.contains(line) {
                                lines.append(line)
                            }
                        }
                    }
                }
            }
        }
        
        lines.sort()
        removeOverlappingLines(&lines)

        return lines
    }
    
    func calculateMelodicLines(segments: [[Segment]]) -> [([CGPoint], Color)] {
        var lines: [([CGPoint], Color)] = []
        
        return lines
    }
    
    func segmentsAreHarmonic(_ segment1: Segment, _ segment2: Segment) -> Bool {
        let segment1Start = segment1.durationPreceeding
        let segment1End = segment1Start + segment1.duration
        let segment2Start = segment2.durationPreceeding
        let segment2End = segment2Start + segment2.duration
        
        return segment1End > segment2Start && segment1Start < segment2End
    }
    
    func removeOverlappingLines(_ lines: inout [Line]) {
        // Iterate through each line
        var index = 0
        while index < lines.count - 1 {
            let line1 = lines[index]
            let line2 = lines[index + 1]
            
            // Check if the x positions are the same
            if line1.startPoint.x == line2.startPoint.x {
                // Check for vertical overlap
                if max(line1.startPoint.y, line1.endPoint.y) > min(line2.startPoint.y, line2.endPoint.y)
                    && min(line1.startPoint.y, line1.endPoint.y) < max(line2.startPoint.y, line2.endPoint.y) {
                    // Remove the longer line
                    if line1.length > line2.length {
                        lines.remove(at: index)
                    } else {
                        lines.remove(at: index + 1)
                    }
                    // Continue with the current index since we've removed a line
                    continue
                }
            }
            
            // Move to the next line
            index += 1
        }
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

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
    @Published var melodicLines: [Line]?
    
    let segments: [[[[Segment]]]]
    let barIndex: Int
    let barWidth: CGFloat
    let rowHeight: CGFloat
    
    init(segments: [[[[Segment]]]], harmonicIntervalLinesType: IntervalLinesType, showMelodicIntervalLines: Bool, barIndex: Int, barWidth: CGFloat, rowHeight: CGFloat) {
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
        
        if showMelodicIntervalLines, let melodicSegments = getMelodicSegments() {
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
    
    func getMelodicSegments() -> [[[Segment]]]? {
        guard segments.indices.contains(0), segments[0].indices.contains(barIndex) else { return nil }
        
        var barSegments: [[[Segment]]] = []
        var staveSegments: [[Segment]] = []
        
        for part in segments {
            let bar = part[barIndex]
            
            for stave in bar {
                staveSegments.append(stave)
            }
        }
        
        barSegments.append(staveSegments)
        
        if segments[0].indices.contains(barIndex + 1) {
            var staveSegments: [[Segment]] = []
            
            for part in segments {
                let bar = part[barIndex]
                
                for stave in bar {
                    staveSegments.append(stave)
                }
            }
            
            barSegments.append(staveSegments)
        }
        
        return barSegments
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
    
    /*
     To Do:
     - Fix missing lines when interval is 0
     - Add lines between bar edges
     */
    func calculateMelodicLines(segments: [[[Segment]]]) -> [Line] {
        guard segments.indices.contains(0) else { return [] }
        
        var lines: [Line] = []
        
        for (groupIndex, segmentGroup) in segments[0].enumerated() {
            var harmonicSegments: [Segment] = []
            
            if !segmentGroup.isEmpty {
                for i in 0..<(segmentGroup.count - 1) {
                    for j in (i + 1)..<segmentGroup.count {
                        let segment1 = segmentGroup[i]
                        let segment2 = segmentGroup[j]
                        
                        if segmentsAreHarmonic(segment1, segment2) {
                            harmonicSegments.append(segment1)
                            harmonicSegments.append(segment2)
                        }
                    }
                }
            }

            let melodicSegments = segmentGroup
                .filter { !harmonicSegments.contains($0) }
                .sorted { $0.durationPreceeding < $1.durationPreceeding }
            
            if !melodicSegments.isEmpty {
                for i in 0..<(melodicSegments.count - 1) {
                    let segment1 = melodicSegments[i]
                    let segment2 = melodicSegments[i + 1]
                    
                    let xStartPosition = barWidth * CGFloat(segment1.durationPreceeding + segment1.duration / 2)
                    let yStartPosition = rowHeight * CGFloat(segment1.rowIndex) + rowHeight / 2
                    let xEndPosition = barWidth * CGFloat(segment2.durationPreceeding + segment2.duration / 2)
                    let yEndPosition = rowHeight * CGFloat(segment2.rowIndex) + rowHeight / 2
                    
                    let startPoint = CGPoint(x: xStartPosition, y: yStartPosition)
                    let endPoint = CGPoint(x: xEndPosition, y: yEndPosition)
                    
                    let intervalColorIndex = (abs(segment1.rowIndex - segment2.rowIndex) - 1) % 12
                    let color = RollViewModel.melodicIntervalLineColors.indices.contains(intervalColorIndex) ? RollViewModel.melodicIntervalLineColors[intervalColorIndex] : Color.clear
                    
                    let line = Line(startPoint: startPoint, endPoint: endPoint, color: color)
                    
                    if !lines.contains(line) {
                        lines.append(line)
                    }
                }
            }
        }
        
        return lines
    }
    
    func segmentsAreHarmonic(_ segment1: Segment, _ segment2: Segment) -> Bool {
        let segment1Start = segment1.durationPreceeding
        let segment1End = segment1Start + segment1.duration
        let segment2Start = segment2.durationPreceeding
        let segment2End = segment2Start + segment2.duration
        
        let epsilon = 0.00001
        
        return segment1End > segment2Start + epsilon && segment1Start + epsilon < segment2End
    }
    
    func removeOverlappingLines(_ lines: inout [Line]) {
        var overlapDetected = true
        
        while overlapDetected {
            overlapDetected = false
            
            if !lines.isEmpty {
                for i in 0..<(lines.count - 1) {
                    for j in (i + 1)..<lines.count {
                        let line1 = lines[i]
                        let line2 = lines[j]
                        
                        if line1.startPoint.x == line2.startPoint.x {
                            if max(line1.startPoint.y, line1.endPoint.y) > min(line2.startPoint.y, line2.endPoint.y)
                                && min(line1.startPoint.y, line1.endPoint.y) < max(line2.startPoint.y, line2.endPoint.y) {
                                if line1.length > line2.length {
                                    lines.remove(at: i)
                                } else {
                                    lines.remove(at: j)
                                }
                                
                                overlapDetected = true
                                break
                            }
                        }
                    }
                    
                    if overlapDetected {
                        break
                    }
                }
            }
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

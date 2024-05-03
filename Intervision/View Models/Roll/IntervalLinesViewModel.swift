//
//  IntervalLinesViewModel.swift
//  Intervision
//
//  Created by Reuben on 01/03/2024.
//

import Foundation
import SwiftUI

class IntervalLinesViewModel: ObservableObject {
    
    @Published var harmonicLines: [Line] = []
    @Published var melodicLines: [Line] = []
    
    let segments: [[[[Segment]]]] // part->bar->stave->segment
    let parts: [Part]
    let groups: [(String, [Part])]
    let harmonicIntervalLinesType: IntervalLinesType
    let showMelodicIntervalLines: Bool
    let barIndex: Int
    let testing: Bool
    
    var barWidth: CGFloat {
        didSet {
            self.calculateLines()
        }
    }
    
    var rowWidth: CGFloat {
        didSet {
            self.calculateLines()
        }
    }
    
    var rowHeight: CGFloat {
        didSet {
            self.calculateLines()
        }
    }
    
    let harmonicIntervalLineColors: [Color]
    let melodicIntervalLineColors: [Color]
    let viewableMelodicLines: [Part]
    let showInvertedIntervals: Bool
    let showZigZags: Bool
    
    init(
        segments: [[[[Segment]]]],
        parts: [Part],
        groups: [(String, [Part])],
        harmonicIntervalLinesType: IntervalLinesType,
        showMelodicIntervalLines: Bool,
        barIndex: Int,
        barWidth: CGFloat,
        rowWidth: CGFloat,
        rowHeight: CGFloat,
        harmonicIntervalLineColors: [Color],
        melodicIntervalLineColors: [Color],
        viewableMelodicLines: [Part],
        showInvertedIntervals: Bool,
        showZigZags: Bool,
        testing: Bool
    ) {
        self.segments = segments
        self.parts = parts
        self.groups = groups
        self.harmonicIntervalLinesType = harmonicIntervalLinesType
        self.showMelodicIntervalLines = showMelodicIntervalLines
        self.barIndex = barIndex
        self.barWidth = barWidth
        self.rowWidth = rowWidth
        self.rowHeight = rowHeight
        self.harmonicIntervalLineColors = harmonicIntervalLineColors
        self.melodicIntervalLineColors = melodicIntervalLineColors
        self.viewableMelodicLines = viewableMelodicLines
        self.showInvertedIntervals = showInvertedIntervals
        self.showZigZags = showZigZags
        self.testing = testing
        
        self.calculateLines()
    }
    
    private func calculateLines() {
        var harmonicSegments: [[Segment]]?
        
        switch self.harmonicIntervalLinesType {
        case .none:
            break
        case .staves:
            harmonicSegments = getStaveSegments()
            break
        case .parts:
            harmonicSegments = getPartSegments()
            break
        case .groups:
            harmonicSegments = getGroupSegments()
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
    
    func getGroupSegments() -> [[Segment]]? {
        guard segments.indices.contains(0), segments[0].indices.contains(barIndex) else { return nil }
        
        var allGroupSegments: [[Segment]] = []
        
        for group in groups {
            var groupSegments: [Segment] = []
            
            for part in group.1 {
                if let index = parts.firstIndex(where: { $0 == part }) {
                    if segments.indices.contains(index) {
                        let partSegments = segments[index]
                        let bar = partSegments[barIndex]
                        
                        for stave in bar {
                            for segment in stave {
                                groupSegments.append(segment)
                            }
                        }
                    }
                }
            }
            
            allGroupSegments.append(groupSegments)
        }
        
        return allGroupSegments
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
        
        var melodicSegments: [[[Segment]]] = []
        
        var previousSegments: [[Segment]] = []
        var currentSegments: [[Segment]] = []
        var nextSegments: [[Segment]] = []
        
        for part in viewableMelodicLines {
            if let index = parts.firstIndex(where: { $0 == part }) {
                if segments.indices.contains(index) {
                    let partSegments = segments[index]
                    let currentBar = partSegments[barIndex]
                    
                    for stave in currentBar {
                        currentSegments.append(stave)
                    }
                }
            }
        }
        
        if segments[0].indices.contains(barIndex - 1) {
            for part in viewableMelodicLines {
                if let index = parts.firstIndex(where: { $0 == part }) {
                    if segments.indices.contains(index) {
                        let partSegments = segments[index]
                        let previousBar = partSegments[barIndex - 1]
                        
                        for stave in previousBar {
                            previousSegments.append(stave)
                        }
                    }
                }
            }
        }
        
        if segments[0].indices.contains(barIndex + 1) {
            for part in viewableMelodicLines {
                if let index = parts.firstIndex(where: { $0 == part }) {
                    if segments.indices.contains(index) {
                        let partSegments = segments[index]
                        let nextBar = partSegments[barIndex + 1]
                        
                        for stave in nextBar {
                            nextSegments.append(stave)
                        }
                    }
                }
            }
        }
        
        melodicSegments.append(previousSegments)
        melodicSegments.append(currentSegments)
        melodicSegments.append(nextSegments)
        
        return melodicSegments
    }
    
    func calculateHarmonicLines(segments: [[Segment]]) -> [Line] {
        var lines: [Line] = []
        
        for segmentGroup in segments {
            var groupLines: [Line] = []
            
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
                            let color = calculateColor(isHarmonic: true, segment1: segment1, segment2: segment2)
                            let inversionType = calculateInversionType(segment1: segment1, segment2: segment2)
                            
                            let line = Line(startPoint: startPoint, endPoint: endPoint, color: color, inversionType: inversionType)
                            
                            if !groupLines.contains(line) {
                                groupLines.append(line)
                            }
                        }
                    }
                }
            }
            
            groupLines.sort()
            
            if self.testing, groupLines.count > 0 {
                for i in 0..<groupLines.count - 1 {
                    if groupLines[i + 1].startPoint.x != groupLines[i].startPoint.x {
                        lines.append(Line(startPoint: groupLines[i].startPoint, endPoint: groupLines[i].endPoint, dotted: true, color: groupLines[i].color, inversionType: groupLines[i].inversionType))
                    }
                }
                
                lines.append(Line(startPoint: groupLines[groupLines.count - 1].startPoint, endPoint: groupLines[groupLines.count - 1].endPoint, dotted: true, color: groupLines[groupLines.count - 1].color, inversionType: groupLines[groupLines.count - 1].inversionType))
                
                for line in lines {
                    let offset = self.barWidth / 4
                    
                    line.startPoint.x += offset
                    line.endPoint.x += offset
                }
            }
            
            removeOverlappingLines(&groupLines)
            
            lines.append(contentsOf: groupLines)
        }

        return lines
    }

    func calculateMelodicLines(segments: [[[Segment]]]) -> [Line] {
        guard segments.count == 3 else { return [] }
        
        var lines: [Line] = []
        
        let previousSegments = segments[0]
        let currentSegments = segments[1]
        let nextsegments = segments[2]
        
        var previousMelodicSegments: [[Segment]] = []
        var currentMelodicSegments: [[Segment]] = []
        var nextMelodicSegments: [[Segment]] = []
        
        for segmentGroup in currentSegments {
            var currentHarmonicSegments: [Segment] = []
            
            if !segmentGroup.isEmpty {
                for i in 0..<(segmentGroup.count - 1) {
                    for j in (i + 1)..<segmentGroup.count {
                        let segment1 = segmentGroup[i]
                        let segment2 = segmentGroup[j]
                        
                        if segmentsAreHarmonic(segment1, segment2) {
                            currentHarmonicSegments.append(segment1)
                            currentHarmonicSegments.append(segment2)
                        }
                    }
                }
            }
            
            currentMelodicSegments.append(
                segmentGroup
                    .filter { !currentHarmonicSegments.contains($0) }
                    .sorted { $0.durationPreceeding < $1.durationPreceeding }
                )
            
            for melodicGroup in currentMelodicSegments {
                if !melodicGroup.isEmpty {
                    for i in 0..<(melodicGroup.count - 1) {
                        let segment1 = melodicGroup[i]
                        let segment2 = melodicGroup[i + 1]
                        
                        let xStartPosition = barWidth * CGFloat(segment1.durationPreceeding + segment1.duration / 2)
                        let yStartPosition = rowHeight * CGFloat(segment1.rowIndex) + rowHeight / 2
                        let xEndPosition = barWidth * CGFloat(segment2.durationPreceeding + segment2.duration / 2)
                        let yEndPosition = rowHeight * CGFloat(segment2.rowIndex) + rowHeight / 2
                        
                        let startPoint = CGPoint(x: xStartPosition, y: yStartPosition)
                        let endPoint = CGPoint(x: xEndPosition, y: yEndPosition)
                        let color = calculateColor(isHarmonic: false, segment1: segment1, segment2: segment2)
                        let inversionType = calculateInversionType(segment1: segment1, segment2: segment2)
                        
                        let line = Line(startPoint: startPoint, endPoint: endPoint, color: color, inversionType: inversionType)
                        
                        if !lines.contains(line) {
                            lines.append(line)
                        }
                    }
                }
            }
        }
        
        for segmentGroup in previousSegments {
            var previousHarmonicSegments: [Segment] = []
            
            if !segmentGroup.isEmpty {
                for i in 0..<(segmentGroup.count - 1) {
                    for j in (i + 1)..<segmentGroup.count {
                        let segment1 = segmentGroup[i]
                        let segment2 = segmentGroup[j]
                        
                        if segmentsAreHarmonic(segment1, segment2) {
                            previousHarmonicSegments.append(segment1)
                            previousHarmonicSegments.append(segment2)
                        }
                    }
                }
            }
            
            previousMelodicSegments.append(
                segmentGroup
                    .filter { !previousHarmonicSegments.contains($0) }
                    .sorted { $0.durationPreceeding < $1.durationPreceeding }
                )
            
            for i in 0..<previousMelodicSegments.count {
                if let trailingSegment = previousMelodicSegments[i].last,
                   let leadingSegment = currentMelodicSegments[i].first {
                    let xStartPosition = barWidth * CGFloat(trailingSegment.durationPreceeding + trailingSegment.duration / 2) - rowWidth
                    let yStartPosition = rowHeight * CGFloat(trailingSegment.rowIndex) + rowHeight / 2
                    let xEndPosition = (barWidth * CGFloat(leadingSegment.durationPreceeding + leadingSegment.duration / 2))
                    let yEndPosition = rowHeight * CGFloat(leadingSegment.rowIndex) + rowHeight / 2
                    
                    let startPoint = CGPoint(x: xStartPosition, y: yStartPosition)
                    let endPoint = CGPoint(x: xEndPosition, y: yEndPosition)
                    let color = calculateColor(isHarmonic: false, segment1: trailingSegment, segment2: leadingSegment)
                    let inversionType = calculateInversionType(segment1: trailingSegment, segment2: leadingSegment)
                    
                    let line = Line(startPoint: startPoint, endPoint: endPoint, color: color, inversionType: inversionType)
                    
                    if !lines.contains(line) {
                        lines.append(line)
                    }
                }
            }
        }
        
        for segmentGroup in nextsegments {
            var nextHarmonicSegments: [Segment] = []
            
            if !segmentGroup.isEmpty {
                for i in 0..<(segmentGroup.count - 1) {
                    for j in (i + 1)..<segmentGroup.count {
                        let segment1 = segmentGroup[i]
                        let segment2 = segmentGroup[j]
                        
                        if segmentsAreHarmonic(segment1, segment2) {
                            nextHarmonicSegments.append(segment1)
                            nextHarmonicSegments.append(segment2)
                        }
                    }
                }
            }
            
            nextMelodicSegments.append(
                segmentGroup
                    .filter { !nextHarmonicSegments.contains($0) }
                    .sorted { $0.durationPreceeding < $1.durationPreceeding }
                )
            
            for i in 0..<nextMelodicSegments.count {
                if let trailingSegment = currentMelodicSegments[i].last,
                   let leadingSegment = nextMelodicSegments[i].first {
                    let xStartPosition = barWidth * CGFloat(trailingSegment.durationPreceeding + trailingSegment.duration / 2)
                    let yStartPosition = rowHeight * CGFloat(trailingSegment.rowIndex) + rowHeight / 2
                    let xEndPosition = (barWidth * CGFloat(leadingSegment.durationPreceeding + leadingSegment.duration / 2)) + rowWidth
                    let yEndPosition = rowHeight * CGFloat(leadingSegment.rowIndex) + rowHeight / 2
                    
                    let startPoint = CGPoint(x: xStartPosition, y: yStartPosition)
                    let endPoint = CGPoint(x: xEndPosition, y: yEndPosition)
                    let color = calculateColor(isHarmonic: false, segment1: trailingSegment, segment2: leadingSegment)
                    let inversionType = calculateInversionType(segment1: trailingSegment, segment2: leadingSegment)
                    
                    let line = Line(startPoint: startPoint, endPoint: endPoint, color: color, inversionType: inversionType)
                    
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
    
    func calculateColor(isHarmonic: Bool, segment1: Segment, segment2: Segment) -> Color {
        let distance = abs(segment1.rowIndex - segment2.rowIndex)
        
        if distance == 0 {
            return (isHarmonic ? harmonicIntervalLineColors.last : melodicIntervalLineColors.last) ?? Color.clear
        }
        
        var index = (distance - 1) % 12
        
        if self.showInvertedIntervals {
            if index == 11 {
                index = 6
            } else if index > 5 {
                index = 10 - index
            }
        }
        
        if isHarmonic {
            return harmonicIntervalLineColors.indices.contains(index) ? harmonicIntervalLineColors[index] : Color.clear
        } else {
            return melodicIntervalLineColors.indices.contains(index) ? melodicIntervalLineColors[index] : Color.clear
        }
    }
    
    func calculateInversionType(segment1: Segment, segment2: Segment) -> Line.InversionType {
        let distance = abs(segment1.rowIndex - segment2.rowIndex)
        let index = (distance - 1) % 12
        
        if index == 0 || index == 11 {
            return .Neither
        } else if index > 5 {
            return .Inverted
        } else {
            return .None
        }
    }
}

extension IntervalLinesViewModel {
    enum IntervalLinesType: String, CaseIterable {
        case none
        case staves
        case parts
        case groups
        case all
    }
}

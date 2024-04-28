//
//  LinesViewModel.swift
//  Intervision
//
//  Created by Reuben on 06/04/2024.
//

import Foundation
import SwiftUI

class LinesViewModel: ObservableObject {
    
    let beatBeamGroupChords: [[Chord]]
    let positions: [[[CGPoint]]]
    let middleStaveNote: Note?
    let barGeometry: GeometryProxy
    let beatGeometry: GeometryProxy
    let noteSize: CGFloat
    let beamDirections: [BeatViewModel.Direction]
    
    let idealStemLength: CGFloat
    let minimumStemLength: CGFloat
    let beamThickness: CGFloat
    let stemThickness: CGFloat
    let tailThickness: CGFloat
    let ledgerThickness: CGFloat
    let beamSpacing: CGFloat
    let durations: [[Note.Duration]]
    let numberOfBeamLines: [[Int]]
    let beamLines: [Line]
    let stemLines: [Line]
    let tailLines: [Line]
    let ledgerLines: [Line]
    let timeModifications: [(CGPoint, Int)]
    
    init
    (
        beamGroups: [[Chord]],
        positions: [[[CGPoint]]],
        middleStaveNote: Note?,
        barGeometry: GeometryProxy,
        beatGeometry: GeometryProxy,
        noteSize: CGFloat,
        beamDirections: [BeatViewModel.Direction]
    ) {
        self.beatBeamGroupChords = beamGroups
        self.positions = positions
        self.middleStaveNote = middleStaveNote
        self.barGeometry = barGeometry
        self.beatGeometry = beatGeometry
        self.noteSize = noteSize
        self.beamDirections = beamDirections
        
        self.idealStemLength = LinesViewModel.calculateIdealStemLength(noteSize: self.noteSize)
        self.minimumStemLength = LinesViewModel.calculateMinimumStemLength(idealStemLength: self.idealStemLength)
        self.beamThickness = LinesViewModel.calculateBeamThickness(barGeometry: self.barGeometry)
        self.stemThickness = LinesViewModel.calculateStemThickness(beamThickness: self.beamThickness)
        self.tailThickness = LinesViewModel.calculateTailThickness(beamThickness: self.beamThickness)
        self.ledgerThickness = LinesViewModel.calculateLedgerThickness(barGeometry: self.barGeometry)
        self.beamSpacing = LinesViewModel.calculateBeamSpacing(idealStemLength: self.idealStemLength)
        self.durations = LinesViewModel.calculateDurations(beatBeamGroupChords: self.beatBeamGroupChords)
        self.numberOfBeamLines = LinesViewModel.calculateNumberOfBeamLines(durations: self.durations)
        
        let lines = LinesViewModel.calculateLines(beatBeamGroupChords: self.beatBeamGroupChords, beamDirections: self.beamDirections, positions: self.positions, numberOfBeamLines: self.numberOfBeamLines, barGeometry: self.barGeometry, idealStemLength: self.idealStemLength, stemThickness: self.stemThickness, noteSize: self.noteSize, beamSpacing: self.beamSpacing, minimumStemLength: self.minimumStemLength)
        
        self.beamLines = lines.0
        self.stemLines = lines.1
        self.tailLines = lines.2
        self.ledgerLines = lines.3
        self.timeModifications = lines.4
    }
}

// Functions
extension LinesViewModel {
    private static func calculateLines(beatBeamGroupChords: [[Chord]], beamDirections: [BeatViewModel.Direction], positions: [[[CGPoint]]], numberOfBeamLines: [[Int]], barGeometry: GeometryProxy, idealStemLength: CGFloat, stemThickness: CGFloat, noteSize: CGFloat, beamSpacing: CGFloat, minimumStemLength: CGFloat) -> ([Line], [Line], [Line], [Line], [(CGPoint, Int)]) {
        var beamLines: [Line] = []
        var stemLines: [Line] = []
        var tailLines: [Line] = []
        var ledgerLines: [Line] = []
        var timeModifications: [(CGPoint, Int)] = []
        
        for groupIndex in 0..<beatBeamGroupChords.count {
            let direction = beamDirections[groupIndex]
            let stemOffset = (direction == .Upward) ? -idealStemLength : idealStemLength
            let xOffset = (direction == .Upward) ? ((noteSize / 2) - (stemThickness / 2)) : ((-noteSize / 2) + (stemThickness / 2))
            let timeModificationOffset = (direction == .Upward) ? -noteSize : noteSize
            var groupTimeModification: Int = -1
            
            for chord in beatBeamGroupChords[groupIndex] {
                if let firstNote = chord.notes.first,
                   let timeModification = firstNote.timeModification {
                    if case .custom(let actual, _, _) = timeModification {
                        groupTimeModification = actual
                    }
                }
            }
            
            for chordPositions in positions[groupIndex] {
                for position in chordPositions {
                    var currentLedgerPoint = CGPoint(x: position.x, y: barGeometry.size.height / 2)
                    var currentLinesAwayFromMiddle = 0
                    let epsilon = 0.0001
                    
                    if position.y > barGeometry.size.height / 2 {
                        while currentLedgerPoint.y <= position.y + epsilon {
                            if currentLinesAwayFromMiddle > 2 {
                                let ledgerStartPoint = CGPoint(x: currentLedgerPoint.x - noteSize * 0.75, y: currentLedgerPoint.y)
                                let ledgerEndPoint = CGPoint(x: currentLedgerPoint.x + noteSize * 0.75, y: currentLedgerPoint.y)
                                
                                ledgerLines.append(Line(startPoint: ledgerStartPoint, endPoint: ledgerEndPoint))
                            }
                            
                            currentLedgerPoint.y += noteSize
                            currentLinesAwayFromMiddle += 1
                        }
                    } else {
                        while currentLedgerPoint.y >= position.y - epsilon {
                            if currentLinesAwayFromMiddle > 2 {
                                let ledgerStartPoint = CGPoint(x: currentLedgerPoint.x - noteSize * 0.75, y: currentLedgerPoint.y)
                                let ledgerEndPoint = CGPoint(x: currentLedgerPoint.x + noteSize * 0.75, y: currentLedgerPoint.y)
                                
                                ledgerLines.append(Line(startPoint: ledgerStartPoint, endPoint: ledgerEndPoint))
                            }
                            
                            currentLedgerPoint.y -= noteSize
                            currentLinesAwayFromMiddle += 1
                        }
                    }
                }
            }
            
            if let firstNotePosition = LinesViewModel.findClosestPositionToBeam(positions: positions[groupIndex][0], direction: direction),
               let lastNotePosition = LinesViewModel.findClosestPositionToBeam(positions: positions[groupIndex][positions[groupIndex].count - 1], direction: direction) {
                
                let startPosition = CGPoint(x: firstNotePosition.x, y: firstNotePosition.y + stemOffset)
                let endPosition = CGPoint(x: lastNotePosition.x, y: lastNotePosition.y + stemOffset)
                
                var yOffset: CGFloat = .zero
                
                let groupPositions = positions[groupIndex]
                
                if groupPositions.count == 1 && groupTimeModification == -1 {
                    if let firstNote = beatBeamGroupChords[groupIndex].first?.notes.first, firstNote.duration.rawValue < 1.0 {
                        let positions = groupPositions[0]
                        
                        if let closestToBeam = LinesViewModel.findClosestPositionToBeam(positions: positions, direction: direction),
                           let furthestFromBeam = LinesViewModel.findFurthestPositionFromBeam(positions: positions, direction: direction) {
                            let stemStartPoint = CGPoint(x: furthestFromBeam.x + xOffset, y: furthestFromBeam.y)
                            let stemEndPoint = CGPoint(x: closestToBeam.x + xOffset, y: closestToBeam.y + stemOffset)
                            
                            stemLines.append(Line(startPoint: stemStartPoint, endPoint: stemEndPoint))
                            
                            if let numberOfTailLines = numberOfBeamLines[groupIndex].first {
                                var beamYOffset: CGFloat = .zero
                                
                                for _ in 0..<numberOfTailLines {
                                    let tailStartPosition = CGPoint(x: stemEndPoint.x, y: stemEndPoint.y + beamYOffset)
                                    let tailEndX = stemEndPoint.x + noteSize
                                    let tailEndY = stemEndPoint.y + ((direction == .Upward) ? noteSize : -noteSize) + beamYOffset
                                    let tailEndPosition = CGPoint(x: tailEndX, y: tailEndY)
                                    
                                    tailLines.append(Line(startPoint: tailStartPosition, endPoint: tailEndPosition))
                                    
                                    beamYOffset += (direction == .Upward) ? beamSpacing : -beamSpacing
                                }
                            }
                        }
                    }
                } else {
                    for positions in groupPositions {
                        if let closestToBeam = LinesViewModel.findClosestPositionToBeam(positions: positions, direction: direction),
                           let yValueAtClosest = LinesViewModel.calculateYValue(atX: closestToBeam.x, forLineWithPoints: startPosition, and: endPosition) {
                            let delta = abs(yValueAtClosest - closestToBeam.y)
                            
                            if delta < minimumStemLength {
                                yOffset = max(yOffset, minimumStemLength - delta)
                            }
                        }
                    }
                    
                    yOffset = (direction == .Upward) ? -yOffset : yOffset
                    
                    let adjustedStartPosition = CGPoint(x: startPosition.x, y: startPosition.y + yOffset)
                    let adjustedEndPosition = CGPoint(x: endPosition.x, y: endPosition.y + yOffset)
                    let numberOfBeamLines = numberOfBeamLines[groupIndex]
                    
                    for (positionsIndex, positions) in groupPositions.enumerated() {
                        if let closestToBeam = LinesViewModel.findClosestPositionToBeam(positions: positions, direction: direction),
                           let furthestFromBeam = LinesViewModel.findFurthestPositionFromBeam(positions: positions, direction: direction) {
                            if positionsIndex > 0 {
                                var beamYOffset: CGFloat = .zero
                                var startIndex: Int = 0
                                
                                if numberOfBeamLines[positionsIndex] == 0 && groupTimeModification != -1 {
                                    beamYOffset = (direction == .Upward) ? -beamSpacing : beamSpacing
                                    startIndex = -1
                                }
                                
                                for i in startIndex..<numberOfBeamLines[positionsIndex] {
                                    if let previousClosestToBeam = LinesViewModel.findClosestPositionToBeam(positions: groupPositions[positionsIndex - 1], direction: direction),
                                       let startYPosition = LinesViewModel.calculateYValue(atX: closestToBeam.x, forLineWithPoints: adjustedStartPosition, and: adjustedEndPosition),
                                       let endYPosition = LinesViewModel.calculateYValue(atX: previousClosestToBeam.x, forLineWithPoints: adjustedStartPosition, and: adjustedEndPosition) {
                                        let beamStartPosition = CGPoint(x: closestToBeam.x + xOffset, y: startYPosition + beamYOffset)
                                        let beamEndPosition = CGPoint(x: previousClosestToBeam.x + xOffset, y: endYPosition + beamYOffset)
                                        let midPoint = LinesViewModel.calculateMidpoint(forLineWithPoints: beamStartPosition, and: beamEndPosition)
                                        let stemStartPosition = CGPoint(x: beamStartPosition.x, y: startIndex == -1 ? beamStartPosition.y - beamYOffset : beamStartPosition.y)
                                        let stemEndPosition = CGPoint(x: furthestFromBeam.x + xOffset, y: furthestFromBeam.y)
                                        
                                        if i <= 0 || positionsIndex == groupPositions.count - 1 || i + 1 <= numberOfBeamLines[positionsIndex - 1] {
                                            beamLines.append(Line(startPoint: beamStartPosition, endPoint: midPoint))
                                        }
                                        
                                        stemLines.append(Line(startPoint: stemStartPosition, endPoint: stemEndPosition))
                                        
                                        if positionsIndex == groupPositions.count / 2 && i <= 0 && groupTimeModification != -1 {
                                            if groupPositions.count % 2 == 0 {
                                                let timeModificationPosition = CGPoint(x: midPoint.x, y: midPoint.y + timeModificationOffset)
                                                
                                                timeModifications.append((timeModificationPosition, groupTimeModification))
                                            } else {
                                                let timeModificationPosition = CGPoint(x: beamStartPosition.x, y: beamStartPosition.y + timeModificationOffset)
                                                
                                                timeModifications.append((timeModificationPosition, groupTimeModification))
                                            }
                                        }
                                        
                                        if positionsIndex == groupPositions.count - 1 && startIndex == -1 {
                                            let beamExtensionX = beamStartPosition.x + noteSize
                                            
                                            if let beamExtensionY = LinesViewModel.calculateYValue(atX: beamExtensionX, forLineWithPoints: beamStartPosition, and: beamEndPosition) {
                                                let beamExtensionPoint = CGPoint(x: beamExtensionX, y: beamExtensionY)
                                                let beamExtensionTowardsStemPoint = CGPoint(x: beamExtensionX, y: beamExtensionY - 1.5 * beamYOffset)
                                                
                                                beamLines.append(Line(startPoint: beamStartPosition, endPoint: beamExtensionPoint))
                                                beamLines.append(Line(startPoint: beamExtensionPoint, endPoint: beamExtensionTowardsStemPoint))
                                            }
                                        }
                                    }
                                    
                                    beamYOffset += (direction == .Upward) ? beamSpacing : -beamSpacing
                                }
                            }
                            
                            if positionsIndex < groupPositions.count - 1 {
                                var beamYOffset: CGFloat = .zero
                                var startIndex: Int = 0
                                
                                if numberOfBeamLines[positionsIndex] == 0 && groupTimeModification != -1 {
                                    beamYOffset = (direction == .Upward) ? -beamSpacing : beamSpacing
                                    startIndex = -1
                                }
                                
                                for i in startIndex..<numberOfBeamLines[positionsIndex] {
                                    if let nextClosestToBeam = LinesViewModel.findClosestPositionToBeam(positions: groupPositions[positionsIndex + 1], direction: direction),
                                       let startYPosition = LinesViewModel.calculateYValue(atX: closestToBeam.x, forLineWithPoints: adjustedStartPosition, and: adjustedEndPosition),
                                       let endYPosition = LinesViewModel.calculateYValue(atX: nextClosestToBeam.x, forLineWithPoints: adjustedStartPosition, and: adjustedEndPosition) {
                                        let beamStartPosition = CGPoint(x: closestToBeam.x + xOffset, y: startYPosition + beamYOffset)
                                        let beamEndPosition = CGPoint(x: nextClosestToBeam.x + xOffset, y: endYPosition + beamYOffset)
                                        let midPoint = LinesViewModel.calculateMidpoint(forLineWithPoints: beamStartPosition, and: beamEndPosition)
                                        
                                        if i <= 0 || positionsIndex == 0 || i + 1 <= numberOfBeamLines[positionsIndex + 1] {
                                            beamLines.append(Line(startPoint: beamStartPosition, endPoint: midPoint))
                                        }
                                        
                                        if positionsIndex == 0 {
                                            let stemStartPosition = CGPoint(x: beamStartPosition.x, y: startIndex == -1 ? beamStartPosition.y - beamYOffset : beamStartPosition.y)
                                            let stemEndPosition = CGPoint(x: furthestFromBeam.x + xOffset, y: furthestFromBeam.y)
                                            
                                            stemLines.append(Line(startPoint: stemStartPosition, endPoint: stemEndPosition))
                                            
                                            if startIndex == -1 {
                                                let beamExtensionX = beamStartPosition.x - noteSize
                                                
                                                if let beamExtensionY = LinesViewModel.calculateYValue(atX: beamExtensionX, forLineWithPoints: beamStartPosition, and: beamEndPosition) {
                                                    let beamExtensionPoint = CGPoint(x: beamExtensionX, y: beamExtensionY)
                                                    let beamExtensionTowardsStemPoint = CGPoint(x: beamExtensionX, y: beamExtensionY - 1.5 * beamYOffset)
                                                    
                                                    beamLines.append(Line(startPoint: beamStartPosition, endPoint: beamExtensionPoint))
                                                    beamLines.append(Line(startPoint: beamExtensionPoint, endPoint: beamExtensionTowardsStemPoint))
                                                }
                                            }
                                        }
                                    }
                                    
                                    beamYOffset += (direction == .Upward) ? beamSpacing : -beamSpacing
                                }
                            }
                            
                            if groupPositions.count == 1 && numberOfBeamLines[0] == 0 && groupTimeModification != -1 {
                                let beamYOffset = (direction == .Upward) ? -beamSpacing : beamSpacing
                                
                                let midPoint = CGPoint(x: closestToBeam.x + xOffset, y: closestToBeam.y + stemOffset + beamYOffset)
                                let leadingBeamExtensionPoint = CGPoint(x: midPoint.x - noteSize, y: midPoint.y)
                                let trailingBeamExtensionPoint = CGPoint(x: midPoint.x + noteSize, y: midPoint.y)
                                let leadingBeamExtensionTowardsStemPoint = CGPoint(x: leadingBeamExtensionPoint.x, y: leadingBeamExtensionPoint.y - 1.5 * beamYOffset)
                                let trailingBeamExtensionTowardsStemPoint = CGPoint(x: trailingBeamExtensionPoint.x, y: trailingBeamExtensionPoint.y - 1.5 * beamYOffset)
                                
                                beamLines.append(Line(startPoint: leadingBeamExtensionPoint, endPoint: trailingBeamExtensionPoint))
                                beamLines.append(Line(startPoint: leadingBeamExtensionPoint, endPoint: leadingBeamExtensionTowardsStemPoint))
                                beamLines.append(Line(startPoint: trailingBeamExtensionPoint, endPoint: trailingBeamExtensionTowardsStemPoint))
                                
                                let timeModificationPosition = CGPoint(x: midPoint.x, y: midPoint.y + timeModificationOffset)
                                
                                timeModifications.append((timeModificationPosition, groupTimeModification))
                                
                                let stemStartPosition = CGPoint(x: furthestFromBeam.x + xOffset, y: furthestFromBeam.y)
                                let stemEndPosition = CGPoint(x: midPoint.x, y: closestToBeam.y + stemOffset)
                                
                                stemLines.append(Line(startPoint: stemStartPosition, endPoint: stemEndPosition))
                            }
                        }
                    }
                }
            }
        }
        
        return (beamLines, stemLines, tailLines, ledgerLines, timeModifications)
    }
    
    private static func calculateYValue(atX x: CGFloat, forLineWithPoints point1: CGPoint, and point2: CGPoint) -> CGFloat? {
        guard point1.x != point2.x else { return point1.y }
        
        let m = (point2.y - point1.y) / (point2.x - point1.x)
        let y = point1.y + m * (x - point1.x)
        
        return y
    }
    
    private static func calculateMidpoint(forLineWithPoints point1: CGPoint, and point2: CGPoint) -> CGPoint {
        let midX = (point1.x + point2.x) / 2.0
        let midY = (point1.y + point2.y) / 2.0
        
        return CGPoint(x: midX, y: midY)
    }
    
    private static func calculateIdealStemLength(noteSize: CGFloat) -> CGFloat {
        return noteSize * 3.5
    }
    
    private static func calculateMinimumStemLength(idealStemLength: CGFloat) -> CGFloat {
        return idealStemLength / 2
    }
    
    private static func calculateBeamThickness(barGeometry: GeometryProxy) -> CGFloat {
        return barGeometry.size.height / 35
    }
    
    private static func calculateStemThickness(beamThickness: CGFloat) -> CGFloat {
        return beamThickness * 0.5
    }
    
    private static func calculateTailThickness(beamThickness: CGFloat) -> CGFloat {
        return beamThickness * 0.75
    }
    
    private static func calculateLedgerThickness(barGeometry: GeometryProxy) -> CGFloat {
        return barGeometry.size.height / 100
    }
    
    private static func calculateBeamSpacing(idealStemLength: CGFloat) -> CGFloat {
        return idealStemLength / 5
    }
    
    private static func calculateDurations(beatBeamGroupChords: [[Chord]]) -> [[Note.Duration]] {
        var durations: [[Note.Duration]] = []
        
        for group in beatBeamGroupChords {
            var groupDurations: [Note.Duration] = []
            
            for chord in group {
                if let firstNote = chord.notes.first {
                    groupDurations.append(firstNote.duration)
                }
            }
            
            durations.append(groupDurations)
        }
        
        return durations
    }
    
    private static func calculateNumberOfBeamLines(durations: [[Note.Duration]]) -> [[Int]] {
        return durations.map { chordDurations in
            return chordDurations.map { duration in
                switch duration {
                    case .eighth: return 1
                    case .sixteenth: return 2
                    case .thirtySecond: return 3
                    case .sixtyFourth: return 4
                    default: return 0
                }
            }
        }
    }
    
    private static func findFurthestPositionFromBeam(positions: [CGPoint], direction: BeatViewModel.Direction) -> CGPoint? {
        guard !positions.isEmpty else { return nil }
        
        switch direction {
            case .Upward:
                return positions.max(by: { $0.y < $1.y })
            case .Downward:
                return positions.min(by: { $0.y < $1.y })
        }
    }
    
    private static func findClosestPositionToBeam(positions: [CGPoint], direction: BeatViewModel.Direction) -> CGPoint? {
        guard !positions.isEmpty else { return nil }
        
        switch direction {
            case .Upward:
                return positions.min(by: { $0.y < $1.y })
            case .Downward:
                return positions.max(by: { $0.y < $1.y })
        }
    }
}

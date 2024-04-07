//
//  LinesViewModel.swift
//  Intervision
//
//  Created by Reuben on 06/04/2024.
//

import Foundation
import SwiftUI

class LinesViewModel: ObservableObject {
    
    let beamGroups: [[Chord]]
    let positions: [[[CGPoint]]]
    let middleStaveNote: Note?
    let barGeometry: GeometryProxy
    let beatGeometry: GeometryProxy
    let noteSize: CGFloat
    
    var beamDirections: [Direction] {
        calculateDirections()
    }
    
    var beamLines: [Line] {
        calculateLines().0
    }
    
    var stemLines: [Line] {
        calculateLines().1
    }
    
    var timeModifications: [(CGPoint, Int)] {
        calculateLines().2
    }
    
    var idealStemLength: CGFloat {
        calculateIdealStemLength()
    }
    
    var minimumStemLength: CGFloat {
        calculateMinimumStemLength()
    }
    
    var beamThickness: CGFloat {
        calculateBeamThickness()
    }
    
    var stemThickness: CGFloat {
        calculateStemThickness()
    }
    
    var beamSpacing: CGFloat {
        calculateBeamSpacing()
    }
    
    var durations: [[Note.Duration]] {
        calculateDurations()
    }
    
    var numberOfBeamLines: [[Int]] {
        calculateNumberOfBeamLines()
    }
    
    init
    (
        beamGroups: [[Chord]],
        positions: [[[CGPoint]]],
        middleStaveNote: Note?,
        barGeometry: GeometryProxy,
        beatGeometry: GeometryProxy,
        noteSize: CGFloat
    ) {
        self.beamGroups = beamGroups
        self.positions = positions
        self.middleStaveNote = middleStaveNote
        self.barGeometry = barGeometry
        self.beatGeometry = beatGeometry
        self.noteSize = noteSize
        
    }
}

// Functions
extension LinesViewModel {
    private func calculateDirections() -> [Direction] {
        var directions: [Direction] = []
        
        for chordGroup in beamGroups {
            var totalDistance = 0
            
            for chord in chordGroup {
                for note in chord.notes {
                    guard !note.isRest, let middleStaveNote = middleStaveNote else { continue }
                    totalDistance += middleStaveNote.calculateDistance(from: middleStaveNote, to: note)
                }
            }
            
            directions.append(totalDistance < 0 ? .Upward : .Downward)
        }
        
        return directions
    }
    
    private func calculateLines() -> ([Line], [Line], [(CGPoint, Int)]) {
        var beamLines: [Line] = []
        var stemLines: [Line] = []
        var timeModifications: [(CGPoint, Int)] = []
        
        for groupIndex in 0..<self.beamGroups.count {
            let direction = self.beamDirections[groupIndex]
            let stemOffset = (direction == .Upward) ? -self.idealStemLength : self.idealStemLength
            let xOffset = (direction == .Upward) ? ((self.noteSize / 2) - (self.stemThickness / 2)) : ((-self.noteSize / 2) + (self.stemThickness / 2))
            let timeModificationOffset = (direction == .Upward) ? -self.noteSize : self.noteSize
            var groupTimeModification: Int = -1
            
            for chord in beamGroups[groupIndex] {
                if let firstNote = chord.notes.first,
                   let timeModification = firstNote.timeModification {
                    if case .custom(let actual, _, _) = timeModification {
                        groupTimeModification = actual
                    }
                }
            }
            
            if let firstNotePosition = findClosestPositionToBeam(positions: self.positions[groupIndex][0], direction: direction),
               let lastNotePosition = findClosestPositionToBeam(positions: self.positions[groupIndex][self.positions[groupIndex].count - 1], direction: direction) {
                
                let startPosition = CGPoint(x: firstNotePosition.x, y: firstNotePosition.y + stemOffset)
                let endPosition = CGPoint(x: lastNotePosition.x, y: lastNotePosition.y + stemOffset)
                
                var yOffset: CGFloat = .zero
                
                let groupPositions = self.positions[groupIndex]
                
                if groupPositions.count == 1 {
                    if let firstNote = self.beamGroups[groupIndex].first?.notes.first, firstNote.duration.rawValue < 1.0 {
                        let positions = groupPositions[0]
                        
                        if let closestToBeam = findClosestPositionToBeam(positions: positions, direction: direction),
                           let furthestFromBeam = findFurthestPositionFromBeam(positions: positions, direction: direction) {
                            let stemStartPoint = CGPoint(x: furthestFromBeam.x + xOffset, y: furthestFromBeam.y)
                            let stemEndPoint = CGPoint(x: closestToBeam.x + xOffset, y: closestToBeam.y + stemOffset)
                            
                            stemLines.append(Line(startPoint: stemStartPoint, endPoint: stemEndPoint))
                        }
                    }
                } else {
                    for positions in groupPositions {
                        if let closestToBeam = findClosestPositionToBeam(positions: positions, direction: direction),
                           let yValueAtClosest = calculateYValue(atX: closestToBeam.x, forLineWithPoints: startPosition, and: endPosition) {
                            let delta = abs(yValueAtClosest - closestToBeam.y)
                            
                            if delta < self.minimumStemLength {
                                yOffset = max(yOffset, minimumStemLength - delta)
                            }
                        }
                    }
                    
                    yOffset = (direction == .Upward) ? -yOffset : yOffset
                    
                    let adjustedStartPosition = CGPoint(x: startPosition.x, y: startPosition.y + yOffset)
                    let adjustedEndPosition = CGPoint(x: endPosition.x, y: endPosition.y + yOffset)
                    let numberOfBeamLines = self.numberOfBeamLines[groupIndex]
                    
                    for (positionsIndex, positions) in groupPositions.enumerated() {
                        if let closestToBeam = findClosestPositionToBeam(positions: positions, direction: direction),
                           let furthestFromBeam = findFurthestPositionFromBeam(positions: positions, direction: direction) {
                            if positionsIndex > 0 {
                                var beamYOffset: CGFloat = .zero
                                var startIndex: Int = 0
                                
                                if numberOfBeamLines[positionsIndex] == 0 && groupTimeModification != -1 {
                                    beamYOffset = (direction == .Upward) ? -self.beamSpacing : self.beamSpacing
                                    startIndex = -1
                                }
                                
                                // fw curr, bw prev
                                
                                for i in startIndex..<numberOfBeamLines[positionsIndex] {
                                    if let previousClosestToBeam = findClosestPositionToBeam(positions: groupPositions[positionsIndex - 1], direction: direction),
                                       let startYPosition = calculateYValue(atX: closestToBeam.x, forLineWithPoints: adjustedStartPosition, and: adjustedEndPosition),
                                       let endYPosition = calculateYValue(atX: previousClosestToBeam.x, forLineWithPoints: adjustedStartPosition, and: adjustedEndPosition) {
                                        let beamStartPosition = CGPoint(x: closestToBeam.x + xOffset, y: startYPosition + beamYOffset)
                                        let beamEndPosition = CGPoint(x: previousClosestToBeam.x + xOffset, y: endYPosition + beamYOffset)
                                        let midPoint = calculateMidpoint(forLineWithPoints: beamStartPosition, and: beamEndPosition)
                                        let stemStartPosition = CGPoint(x: beamStartPosition.x, y: startIndex == -1 ? beamStartPosition.y - beamYOffset : beamStartPosition.y)
                                        let stemEndPosition = CGPoint(x: furthestFromBeam.x + xOffset, y: furthestFromBeam.y)
                                        
                                        beamLines.append(Line(startPoint: beamStartPosition, endPoint: midPoint, color: .red))
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
                                            let beamExtensionX = beamStartPosition.x + self.noteSize
                                            
                                            if let beamExtensionY = calculateYValue(atX: beamExtensionX, forLineWithPoints: beamStartPosition, and: beamEndPosition) {
                                                let beamExtensionPoint = CGPoint(x: beamExtensionX, y: beamExtensionY)
                                                let beamExtensionTowardsStemPoint = CGPoint(x: beamExtensionX, y: beamExtensionY - 1.5 * beamYOffset)
                                                
                                                beamLines.append(Line(startPoint: beamStartPosition, endPoint: beamExtensionPoint))
                                                beamLines.append(Line(startPoint: beamExtensionPoint, endPoint: beamExtensionTowardsStemPoint))
                                            }
                                        }
                                    }
                                    
                                    beamYOffset += (direction == .Upward) ? self.beamSpacing : -self.beamSpacing
                                }
                            }
                            
                            if positionsIndex < groupPositions.count - 1 {
                                var beamYOffset: CGFloat = .zero
                                var startIndex: Int = 0
                                
                                if numberOfBeamLines[positionsIndex] == 0 && groupTimeModification != -1 {
                                    beamYOffset = (direction == .Upward) ? -self.beamSpacing : self.beamSpacing
                                    startIndex = -1
                                }
                                
                                for _ in startIndex..<numberOfBeamLines[positionsIndex] {
                                    if let nextClosestToBeam = findClosestPositionToBeam(positions: groupPositions[positionsIndex + 1], direction: direction),
                                       let startYPosition = calculateYValue(atX: closestToBeam.x, forLineWithPoints: adjustedStartPosition, and: adjustedEndPosition),
                                       let endYPosition = calculateYValue(atX: nextClosestToBeam.x, forLineWithPoints: adjustedStartPosition, and: adjustedEndPosition) {
                                        let beamStartPosition = CGPoint(x: closestToBeam.x + xOffset, y: startYPosition + beamYOffset)
                                        let beamEndPosition = CGPoint(x: nextClosestToBeam.x + xOffset, y: endYPosition + beamYOffset)
                                        let midPoint = calculateMidpoint(forLineWithPoints: beamStartPosition, and: beamEndPosition)
                                        
                                        beamLines.append(Line(startPoint: beamStartPosition, endPoint: midPoint, color: .blue))
                                        
                                        if positionsIndex == 0 {
                                            let stemStartPosition = CGPoint(x: beamStartPosition.x, y: startIndex == -1 ? beamStartPosition.y - beamYOffset : beamStartPosition.y)
                                            let stemEndPosition = CGPoint(x: furthestFromBeam.x + xOffset, y: furthestFromBeam.y)
                                            
                                            stemLines.append(Line(startPoint: stemStartPosition, endPoint: stemEndPosition))
                                            
                                            if startIndex == -1 {
                                                let beamExtensionX = beamStartPosition.x - self.noteSize
                                                
                                                if let beamExtensionY = calculateYValue(atX: beamExtensionX, forLineWithPoints: beamStartPosition, and: beamEndPosition) {
                                                    let beamExtensionPoint = CGPoint(x: beamExtensionX, y: beamExtensionY)
                                                    let beamExtensionTowardsStemPoint = CGPoint(x: beamExtensionX, y: beamExtensionY - 1.5 * beamYOffset)
                                                    
                                                    beamLines.append(Line(startPoint: beamStartPosition, endPoint: beamExtensionPoint))
                                                    beamLines.append(Line(startPoint: beamExtensionPoint, endPoint: beamExtensionTowardsStemPoint))
                                                }
                                            }
                                        }
                                    }
                                    
                                    beamYOffset += (direction == .Upward) ? self.beamSpacing : -self.beamSpacing
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return (beamLines, stemLines, timeModifications)
    }
    
    private func calculateYValue(atX x: CGFloat, forLineWithPoints point1: CGPoint, and point2: CGPoint) -> CGFloat? {
        guard point1.x != point2.x else { return point1.y }
        
        let m = (point2.y - point1.y) / (point2.x - point1.x)
        let y = point1.y + m * (x - point1.x)
        
        return y
    }
    
    private func calculateMidpoint(forLineWithPoints point1: CGPoint, and point2: CGPoint) -> CGPoint {
        let midX = (point1.x + point2.x) / 2.0
        let midY = (point1.y + point2.y) / 2.0
        
        return CGPoint(x: midX, y: midY)
    }
    
    private func calculateIdealStemLength() -> CGFloat {
        return self.beatGeometry.size.height / 3.5
    }
    
    private func calculateMinimumStemLength() -> CGFloat {
        return self.beatGeometry.size.height / 5
    }
    
    private func calculateBeamThickness() -> CGFloat {
        return self.beatGeometry.size.height / 35
    }
    
    private func calculateStemThickness() -> CGFloat {
        return self.barGeometry.size.width / 250
    }
    
    private func calculateBeamSpacing() -> CGFloat {
        return self.idealStemLength / 5
    }
    
    private func calculateDurations() -> [[Note.Duration]] {
        var durations: [[Note.Duration]] = []
        
        for group in self.beamGroups {
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
    
    private func calculateNumberOfBeamLines() -> [[Int]] {
        return self.durations.map { chordDurations in
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
    
    private func findFurthestPositionFromBeam(positions: [CGPoint], direction: Direction) -> CGPoint? {
        guard !positions.isEmpty else { return nil }
        
        switch direction {
            case .Upward:
                return positions.max(by: { $0.y < $1.y })
            case .Downward:
                return positions.min(by: { $0.y < $1.y })
        }
    }
    
    private func findClosestPositionToBeam(positions: [CGPoint], direction: Direction) -> CGPoint? {
        guard !positions.isEmpty else { return nil }
        
        switch direction {
            case .Upward:
                return positions.min(by: { $0.y < $1.y })
            case .Downward:
                return positions.max(by: { $0.y < $1.y })
        }
    }
}

extension LinesViewModel {
    enum Direction {
        case Upward, Downward
    }
}

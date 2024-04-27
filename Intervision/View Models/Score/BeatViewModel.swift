//
//  BeatViewModel.swift
//  Intervision
//
//  Created by Reuben on 06/04/2024.
//

import Foundation
import SwiftUI

class BeatViewModel: ObservableObject {
    
    let beatNoteGrid: [[[Note]?]]
    let barGeometry: GeometryProxy
    let beatGeometry: GeometryProxy
    let beatBeamGroupChords: [[Chord]]
    let middleStaveNote: Note?
    
    let noteSize: CGFloat
    let notePositions: [[(CGPoint, Int)]]
    let restPositions: [CGPoint]
    let groupPositions: [[[CGPoint]]]
    let isHollow: [Bool]
    let noteIsDotted: [Bool]
    let restIsDotted: [Bool]
    let restDurations: [Note.Duration]
    
    init
    (
        noteGrid: [[[Note]?]],
        barGeometry: GeometryProxy,
        beatGeometry: GeometryProxy,
        beamGroupChords: [[Chord]],
        middleStaveNote: Note?
    ) {
        self.beatNoteGrid = noteGrid
        self.barGeometry = barGeometry
        self.beatGeometry = beatGeometry
        self.beatBeamGroupChords = beamGroupChords
        self.middleStaveNote = middleStaveNote
        
        self.noteSize = BeatViewModel.calculateNoteSize(beatGeometry: self.beatGeometry, beatNoteGrid: self.beatNoteGrid)
        
        let positions = BeatViewModel.calculatePositions(beatGeometry: self.beatGeometry, beatNoteGrid: self.beatNoteGrid)
        
        self.notePositions = positions.0
        self.restPositions = positions.1
        
        self.groupPositions = BeatViewModel.calculateGroupPositions(beatBeamGroupChords: self.beatBeamGroupChords, notePositions: self.notePositions)
        self.isHollow = BeatViewModel.calculateIsHollow(beatNoteGrid: self.beatNoteGrid)
        
        let isDotted = BeatViewModel.calculateIsDotted(beatNoteGrid: self.beatNoteGrid)
        
        self.noteIsDotted = isDotted.0
        self.restIsDotted = isDotted.1
        
        self.restDurations = BeatViewModel.calculateRestDurations(beatNoteGrid: self.beatNoteGrid)
    }
}

extension BeatViewModel {
    private static func calculateNoteSize(beatGeometry: GeometryProxy, beatNoteGrid: [[[Note]?]]) -> CGFloat {
        return 2 * (beatGeometry.size.height / CGFloat(beatNoteGrid[0].count - 1))
    }
    
    private static func calculatePositions(beatGeometry: GeometryProxy, beatNoteGrid: [[[Note]?]]) -> ([[(CGPoint, Int)]], [CGPoint]) {
        var notePositions: [[(CGPoint, Int)]] = []
        var restPositions: [CGPoint] = []
        
        for (columnIndex, column) in beatNoteGrid.enumerated() {
            var chordPositions: [(CGPoint, Int)] = []
            
            for (rowIndex, row) in column.enumerated() {
                if let notes = row {
                    for note in notes {
                        let isRest = note.isRest
                        let xPosition = (beatNoteGrid.count == 1) ? 0 : (beatGeometry.size.width / CGFloat(beatNoteGrid.count - 1)) * CGFloat(columnIndex)
                        let yPosition = isRest ? beatGeometry.size.height / 2 : (beatGeometry.size.height / CGFloat(column.count - 1)) * CGFloat(rowIndex)
                        let position = CGPoint(x: xPosition, y: yPosition)
                        
                        if isRest {
                            restPositions.append(position)
                        } else {
                            if rowIndex % 2 != 0 && (rowIndex < column.count - 1 && column[rowIndex + 1] != nil && !(column[rowIndex + 1]?.first?.isRest ?? false) || rowIndex > 0 && column[rowIndex - 1] != nil && !(column[rowIndex - 1]?.first?.isRest ?? false)) {
                                let middle: Double = Double(column.count) / 2
                                var sum: Double = 0
                                var count: Double = 0
                                
                                for (rowIndex, row) in column.enumerated() {
                                    if let notes = row,
                                       let first = notes.first, !first.isRest {
                                        sum += Double(rowIndex)
                                        count += 1
                                    }
                                }
                                
                                chordPositions.append((position, sum / count < middle ? -1 : 1))
                            } else {
                                chordPositions.append((position, 0))
                            }
                        }
                    }
                }
            }
            
            if !chordPositions.isEmpty {
                notePositions.append(chordPositions)
            }
        }
        
        return (notePositions, restPositions)
    }
    
    private static func calculateGroupPositions(beatBeamGroupChords: [[Chord]], notePositions: [[(CGPoint, Int)]]) -> [[[CGPoint]]] {
        var groupPositions: [[[CGPoint]]] = []
        var currentIndex = 0
        
        for group in beatBeamGroupChords {
            var currentPositions: [[CGPoint]] = []
            
            for _ in 0..<group.count {
                currentPositions.append(notePositions[currentIndex].compactMap { $0.0 })
                currentIndex += 1
            }
            
            groupPositions.append(currentPositions)
        }
        
        return groupPositions
    }
    
    private static func calculateIsHollow(beatNoteGrid: [[[Note]?]]) -> [Bool] {
        var isHollow: [Bool] = []
        
        for column in beatNoteGrid {
            var chordIsHollow = false
            
            for row in column {
                if let notes = row {
                    for note in notes {
                        if !note.isRest && note.duration.rawValue >= 0.5 {
                            chordIsHollow = true
                        }
                    }
                }
            }

            isHollow.append(chordIsHollow)
        }
        
        return isHollow
    }
    
    private static func calculateIsDotted(beatNoteGrid: [[[Note]?]]) -> ([Bool], [Bool]) {
        var noteIsDotted: [Bool] = []
        var restIsDotted: [Bool] = []
        
        for column in beatNoteGrid {
            var chordIsDotted: Bool?
            
            for row in column {
                if let notes = row {
                    for note in notes {
                        if note.isRest {
                            restIsDotted.append(note.isDotted)
                        } else {
                            chordIsDotted = note.isDotted
                        }
                    }
                }
            }
            
            if let chordIsDotted = chordIsDotted {
                noteIsDotted.append(chordIsDotted)
            }
        }
        
        return (noteIsDotted, restIsDotted)
    }
    
    private static func calculateRestDurations(beatNoteGrid: [[[Note]?]]) -> [Note.Duration] {
        var restDurations: [Note.Duration] = []

        for column in beatNoteGrid {
            for row in column {
                if let notes = row {
                    for note in notes {
                        if note.isRest {
                            restDurations.append(note.duration)
                        }
                    }
                }
            }
        }
        
        return restDurations
    }
}

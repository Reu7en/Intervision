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
    let pageWidth: CGFloat
    
    var noteSize: CGFloat {
        calculateNoteSize()
    }
    
    var notePositions: [[CGPoint]] {
        calculatePositions().0
    }
    
    var restPositions: [CGPoint] {
        calculatePositions().1
    }
    
    var groupPositions: [[[CGPoint]]] {
        calculateGroupPositions()
    }
    
    var isHollow: [Bool] {
        calculateIsHollow()
    }
    
    var noteIsDotted: [Bool] {
        calculateIsDotted().0
    }
    
    var restIsDotted: [Bool] {
        calculateIsDotted().1
    }
    
    var restDurations: [Note.Duration] {
        calculateRestDurations()
    }
    
    init
    (
        noteGrid: [[[Note]?]],
        barGeometry: GeometryProxy,
        beatGeometry: GeometryProxy,
        beamGroupChords: [[Chord]],
        middleStaveNote: Note?,
        pageWidth: CGFloat
    ) {
        self.beatNoteGrid = noteGrid
        self.barGeometry = barGeometry
        self.beatGeometry = beatGeometry
        self.beatBeamGroupChords = beamGroupChords
        self.middleStaveNote = middleStaveNote
        self.pageWidth = pageWidth
    }
}

extension BeatViewModel {
    private func calculateNoteSize() -> CGFloat {
        return 2 * (self.beatGeometry.size.height / CGFloat(self.beatNoteGrid[0].count - 1))
    }
    
    private func calculatePositions() -> ([[CGPoint]], [CGPoint]) {
        var notePositions: [[CGPoint]] = []
        var restPositions: [CGPoint] = []
        
        for (columnIndex, column) in self.beatNoteGrid.enumerated() {
            var chordPositions: [CGPoint] = []
            
            for (rowIndex, row) in column.enumerated() {
                if let notes = row {
                    for note in notes {
                        let isRest = note.isRest
                        let xPosition = (self.beatNoteGrid.count == 1) ? 0 : (self.beatGeometry.size.width / CGFloat(self.beatNoteGrid.count - 1)) * CGFloat(columnIndex)
                        let yPosition = isRest ? self.beatGeometry.size.height / 2 : (self.beatGeometry.size.height / CGFloat(column.count - 1)) * CGFloat(rowIndex)
                        let position = CGPoint(x: xPosition, y: yPosition)
                        
                        if isRest {
                            restPositions.append(position)
                        } else {
                            chordPositions.append(position)
                        }
                    }
                }
            }
            
            if !chordPositions.isEmpty {
                notePositions.append(chordPositions)
            }
        }
        
        var groupPositions: [[[CGPoint]]] = []
        var currentIndex = 0
        
        for group in self.beatBeamGroupChords {
            let groupCount = group.count
            var currentPositions: [[CGPoint]] = []
            
            for _ in 0..<groupCount {
                currentPositions.append(notePositions[currentIndex])
                currentIndex += 1
            }
            
            groupPositions.append(currentPositions)
        }
        
        return (notePositions, restPositions)
    }
    
    private func calculateGroupPositions() -> [[[CGPoint]]] {
        var groupPositions: [[[CGPoint]]] = []
        var currentIndex = 0
        
        for group in self.beatBeamGroupChords {
            var currentPositions: [[CGPoint]] = []
            
            for _ in 0..<group.count {
                currentPositions.append(self.notePositions[currentIndex])
                currentIndex += 1
            }
            
            groupPositions.append(currentPositions)
        }
        
        return groupPositions
    }
    
    private func calculateIsHollow() -> [Bool] {
        var isHollow: [Bool] = []
        
        for column in self.beatNoteGrid {
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
    
    private func calculateIsDotted() -> ([Bool], [Bool]) {
        var noteIsDotted: [Bool] = []
        var restIsDotted: [Bool] = []
        
        for column in self.beatNoteGrid {
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
    
    private func calculateRestDurations() -> [Note.Duration] {
        var restDurations: [Note.Duration] = []

        for column in self.beatNoteGrid {
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

//
//  BeatViewModel.swift
//  Intervision
//
//  Created by Reuben on 06/04/2024.
//

import Foundation
import SwiftUI

class BeatViewModel: ObservableObject {
    
    let noteGrid: [[Note?]]
    let barGeometry: GeometryProxy
    let beatGeometry: GeometryProxy
    let beamGroupChords: [[Chord]]
    let middleStaveNote: Note?
    
    var noteSize: CGFloat {
        calculateNoteSize()
    }
    
    var notePositions: [[[CGPoint]]] {
        calculatePositions().0
    }
    
    var restPositions: [CGPoint] {
        calculatePositions().1
    }
    
    var isHollow: [[Bool]] {
        calculateIsHollow()
    }
    
    var noteIsDotted: [[Bool]] {
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
        noteGrid: [[Note?]],
        barGeometry: GeometryProxy,
        beatGeometry: GeometryProxy,
        beamGroupChords: [[Chord]],
        middleStaveNote: Note?
    ) {
        self.noteGrid = noteGrid
        self.barGeometry = barGeometry
        self.beatGeometry = beatGeometry
        self.beamGroupChords = beamGroupChords
        self.middleStaveNote = middleStaveNote
    }
}

extension BeatViewModel {
    private func calculateNoteSize() -> CGFloat {
        return 2 * (self.beatGeometry.size.height / CGFloat(self.noteGrid[0].count - 1))
    }
    
    private func calculatePositions() -> ([[[CGPoint]]], [CGPoint]) {
        var notePositions: [[CGPoint]] = []
        var restPositions: [CGPoint] = []
        
        let rows = noteGrid.count
        
        for rowIndex in 0..<rows {
            let columns = noteGrid[rowIndex].count
            var chordPositions: [CGPoint] = []
            
            for columnIndex in 0..<columns {
                if let note = noteGrid[rowIndex][columnIndex] {
                    let isRest = note.isRest
                    let xPosition = (rows == 1) ? 0 : (self.beatGeometry.size.width / CGFloat(rows - 1)) * CGFloat(rowIndex)
                    let yPosition = isRest ? self.beatGeometry.size.height / 2 : (self.beatGeometry.size.height / CGFloat(columns - 1)) * CGFloat(columnIndex)
                    let position = CGPoint(x: xPosition, y: yPosition)
                    
                    if isRest {
                        restPositions.append(position)
                    } else {
                        chordPositions.append(position)
                    }
                }
            }
            
            if !chordPositions.isEmpty {
                notePositions.append(chordPositions)
            }
        }
        
        var groupPositions: [[[CGPoint]]] = []
        var currentIndex = 0
        
        for group in self.beamGroupChords {
            let groupCount = group.count
            var currentPositions: [[CGPoint]] = []
            
            for _ in 0..<groupCount {
                currentPositions.append(notePositions[currentIndex])
                currentIndex += 1
            }
            
            groupPositions.append(currentPositions)
        }
        
        return (groupPositions, restPositions)
    }
    
    private func calculateIsHollow() -> [[Bool]] {
        var isHollow: [[Bool]] = []
        
        let rows = noteGrid.count
        
        for rowIndex in 0..<rows {
            let columns = noteGrid[rowIndex].count
            var chordIsHollow: [Bool] = []
            
            for columnIndex in 0..<columns {
                if let note = noteGrid[rowIndex][columnIndex] {
                    if !note.isRest {
                        if note.duration.rawValue >= 0.5 {
                            chordIsHollow.append(true)
                        } else {
                            chordIsHollow.append(false)
                        }
                    }
                }
            }
            
            if !chordIsHollow.isEmpty {
                isHollow.append(chordIsHollow)
            }
        }
        
        return isHollow
    }
    
    private func calculateIsDotted() -> ([[Bool]], [Bool]) {
        var noteIsDotted: [[Bool]] = []
        var restIsDotted: [Bool] = []
        
        let rows = noteGrid.count
        
        for rowIndex in 0..<rows {
            let columns = noteGrid[rowIndex].count
            var chordIsDotted: [Bool] = []
            
            for columnIndex in 0..<columns {
                if let note = noteGrid[rowIndex][columnIndex] {
                    if !note.isRest {
                        if note.isDotted {
                            chordIsDotted.append(true)
                        } else {
                            chordIsDotted.append(false)
                        }
                    } else {
                        if note.isDotted {
                            restIsDotted.append(true)
                        } else {
                            restIsDotted.append(false)
                        }
                    }
                }
            }
            
            if !chordIsDotted.isEmpty {
                noteIsDotted.append(chordIsDotted)
            }
        }
        
        return (noteIsDotted, restIsDotted)
    }
    
    private func calculateRestDurations() -> [Note.Duration] {
        var restDurations: [Note.Duration] = []
        
        let rows = noteGrid.count
        
        for rowIndex in 0..<rows {
            let columns = noteGrid[rowIndex].count
            
            for columnIndex in 0..<columns {
                if let note = noteGrid[rowIndex][columnIndex] {
                    if note.isRest {
                        restDurations.append(note.duration)
                    }
                }
            }
        }
        
        return restDurations
    }
}

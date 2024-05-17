//
//  BeatViewModel.swift
//  Intervision
//
//  Created by Reuben on 06/04/2024.
//

import Foundation
import SwiftUI

class BeatViewModel: ObservableObject {
    
    var beatNoteGrid: [[[(Note, Note.Accidental?)]?]]
    let barGeometry: GeometryProxy
    let beatGeometry: GeometryProxy
    var beatBeamGroupChords: [[Chord]]
    let middleStaveNote: Note?
    
    let noteSize: CGFloat
    var beamDirections: [Direction]
    var notePositions: [[(CGPoint, Int)]]
    let restPositions: [CGPoint]
    let accidentalPositions: [(CGPoint, Int)]
    let groupPositions: [[[(CGPoint, Int)]]]
    let isHollow: [Bool]
    let noteIsDotted: [Bool]
    let restIsDotted: [Bool]
    let restDurations: [Note.Duration]
    let accidentals: [Note.Accidental]
    
    init
    (
        noteGrid: inout [[[(Note, Note.Accidental?)]?]],
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
        
        self.noteSize = BeatViewModel.calculateNoteSize(beatGeometry: self.beatGeometry, beatNoteGrid: &self.beatNoteGrid)
        self.beamDirections = BeatViewModel.calculateDirections(beatBeamGroupChords: &self.beatBeamGroupChords, middleStaveNote: self.middleStaveNote)
        
        let positions = BeatViewModel.calculatePositions(beatGeometry: self.beatGeometry, beatNoteGrid: &self.beatNoteGrid, beatBeamGroupChords: &self.beatBeamGroupChords, beamDirections: &self.beamDirections)
        
        self.notePositions = positions.0
        self.restPositions = positions.1
        self.accidentalPositions = positions.2
        
        self.groupPositions = BeatViewModel.calculateGroupPositions(beatBeamGroupChords: &self.beatBeamGroupChords, notePositions: &self.notePositions)
        self.isHollow = BeatViewModel.calculateIsHollow(beatNoteGrid: &self.beatNoteGrid)
        
        let isDotted = BeatViewModel.calculateIsDotted(beatNoteGrid: &self.beatNoteGrid)
        
        self.noteIsDotted = isDotted.0
        self.restIsDotted = isDotted.1
        
        self.restDurations = BeatViewModel.calculateRestDurations(beatNoteGrid: &self.beatNoteGrid)
        self.accidentals = BeatViewModel.calculateAccidentals(beatNoteGrid: &self.beatNoteGrid)
        
    }
}

extension BeatViewModel {
    enum Direction {
        case Upward, Downward
    }
}

extension BeatViewModel {
    private static func calculateNoteSize(beatGeometry: GeometryProxy, beatNoteGrid: inout [[[(Note, Note.Accidental?)]?]]) -> CGFloat {
        return 2 * (beatGeometry.size.height / CGFloat(beatNoteGrid[0].count - 1))
    }
    
    private static func calculateDirections(beatBeamGroupChords: inout [[Chord]], middleStaveNote: Note?) -> [Direction] {
        var directions: [Direction] = []
        
        for chordGroup in beatBeamGroupChords {
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
    
    private static func calculatePositions(beatGeometry: GeometryProxy, beatNoteGrid: inout [[[(Note, Note.Accidental?)]?]], beatBeamGroupChords: inout [[Chord]], beamDirections: inout [Direction]) -> ([[(CGPoint, Int)]], [CGPoint], [(CGPoint, Int)]) {
        var notePositions: [[(CGPoint, Int)]] = []
        var restPositions: [CGPoint] = []
        var accidentalPositions: [(CGPoint, Int)] = []
        
        var currentChordIndex = 0
        var currentBeamIndex = 0
        
        guard !beatNoteGrid.isEmpty else { return (notePositions, restPositions, accidentalPositions) }
//        guard !beatBeamGroupChords.isEmpty else { return (notePositions, restPositions, accidentalPositions) } // If this is causing issues, enabling it means rests in solo group dont render
        
        for (columnIndex, column) in beatNoteGrid.enumerated() {
//            if currentChordIndex == beatBeamGroupChords[currentBeamIndex].count { // Also disabled
            if !beatBeamGroupChords.isEmpty, currentChordIndex == beatBeamGroupChords[currentBeamIndex].count {
                currentBeamIndex += 1
                currentChordIndex = 0
            }
            
            var chordPositions: [(CGPoint, Int)] = []
            
            for (rowIndex, row) in column.enumerated() {
                if let notes = row {
                    for (noteIndex, note) in notes.enumerated() {
                        let isRest = note.0.isRest
                        let hasAccidental = note.1 != nil
                        let xPosition = (beatNoteGrid.count == 1) ? 0 : (beatGeometry.size.width / CGFloat(beatNoteGrid.count - 1)) * CGFloat(columnIndex)
                        let yPosition = isRest ? beatGeometry.size.height / 2 : (beatGeometry.size.height / CGFloat(column.count - 1)) * CGFloat(rowIndex)
                        let position = CGPoint(x: xPosition, y: yPosition)
                        
                        if isRest {
                            restPositions.append(position)
                        } else {
                            if chordPositions.isEmpty {
                                currentChordIndex += 1
                            }
                            
                            if rowIndex % 2 != 0 && (rowIndex < column.count - 1 && column[rowIndex + 1] != nil && !(column[rowIndex + 1]?.first?.0.isRest ?? false) || rowIndex > 0 && column[rowIndex - 1] != nil && !(column[rowIndex - 1]?.first?.0.isRest ?? false)) {
                                chordPositions.append((position, noteIndex == 0 ? (beamDirections[currentBeamIndex] == .Upward ? 1 : -1) : 0))
                                
                                if hasAccidental {
                                    if (rowIndex < column.count - 1 && column[rowIndex + 1] != nil && !((column[rowIndex + 1] ?? []).allSatisfy({ $0.1 == nil })) || rowIndex > 0 && column[rowIndex - 1] != nil && !((column[rowIndex - 1] ?? []).allSatisfy({ $0.1 == nil }))) {
                                        accidentalPositions.append((position, beamDirections[currentBeamIndex] == .Upward ? -1 : -3))
                                    } else {
                                        accidentalPositions.append((position, beamDirections[currentBeamIndex] == .Upward ? -1 : -2))
                                    }
                                }
                            } else {
                                if notes.count == 2 {
                                    chordPositions.append((position, noteIndex == 1 ? (beamDirections[currentBeamIndex] == .Upward ? 1 : -1) : 0))
                                    
                                    if hasAccidental {
                                        if noteIndex == 0 {
                                            if notes[0].1 == nil {
                                                accidentalPositions.append((position, beamDirections[currentBeamIndex] == .Upward ? -1 : -2))
                                            } else {
                                                accidentalPositions.append((position, beamDirections[currentBeamIndex] == .Upward ? -2 : -3))
                                            }
                                        } else {
                                            accidentalPositions.append((position, beamDirections[currentBeamIndex] == .Upward ? -1 : -2))
                                        }
                                    }
                                } else {
                                    chordPositions.append((position, 0))
                                    
                                    if hasAccidental {
                                        if (rowIndex < column.count - 1 && column[rowIndex + 1] != nil && !(column[rowIndex + 1]?.first?.0.isRest ?? false) || rowIndex > 0 && column[rowIndex - 1] != nil && !(column[rowIndex - 1]?.first?.0.isRest ?? false)) {
                                            if (rowIndex < column.count - 1 && column[rowIndex + 1] != nil && !((column[rowIndex + 1] ?? []).allSatisfy({ $0.1 == nil })) || rowIndex > 0 && column[rowIndex - 1] != nil && !((column[rowIndex - 1] ?? []).allSatisfy({ $0.1 == nil }))) {
                                                accidentalPositions.append((position, -2))
                                            } else {
                                                accidentalPositions.append((position, beamDirections[currentBeamIndex] == .Upward ? -1 : -2))
                                            }
                                        } else {
                                            accidentalPositions.append((position, -1))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if !chordPositions.isEmpty {
                notePositions.append(chordPositions)
            }
        }
        
        return (notePositions, restPositions, accidentalPositions)
    }
    
    private static func calculateGroupPositions(beatBeamGroupChords: inout [[Chord]], notePositions: inout [[(CGPoint, Int)]]) -> [[[(CGPoint, Int)]]] {
        guard !notePositions.isEmpty else { return [] }
        var groupPositions: [[[(CGPoint, Int)]]] = []
        var currentIndex = 0
        
        for group in beatBeamGroupChords {
            var currentPositions: [[(CGPoint, Int)]] = []
            
            for _ in 0..<group.count {
                currentPositions.append(notePositions[currentIndex].compactMap( { $0 } ))
                currentIndex += 1
            }
            
            groupPositions.append(currentPositions)
        }
        
        return groupPositions
    }
    
    private static func calculateIsHollow(beatNoteGrid: inout [[[(Note, Note.Accidental?)]?]]) -> [Bool] {
        var isHollow: [Bool] = []
        
        for column in beatNoteGrid {
            var chordIsHollow = false
            
            for row in column {
                if let notes = row {
                    for note in notes {
                        if !note.0.isRest && note.0.duration.rawValue >= 0.5 {
                            chordIsHollow = true
                        }
                    }
                }
            }

            isHollow.append(chordIsHollow)
        }
        
        return isHollow
    }
    
    private static func calculateIsDotted(beatNoteGrid: inout [[[(Note, Note.Accidental?)]?]]) -> ([Bool], [Bool]) {
        var noteIsDotted: [Bool] = []
        var restIsDotted: [Bool] = []
        
        for column in beatNoteGrid {
            var chordIsDotted: Bool?
            
            for row in column {
                if let notes = row {
                    for note in notes {
                        if note.0.isRest {
                            restIsDotted.append(note.0.isDotted)
                        } else {
                            chordIsDotted = note.0.isDotted
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
    
    private static func calculateAccidentals(beatNoteGrid: inout [[[(Note, Note.Accidental?)]?]]) -> [Note.Accidental] {
        var accidentals: [Note.Accidental] = []
        
        for column in beatNoteGrid {
            for row in column {
                if let notes = row {
                    for note in notes {
                        if let accidental = note.1 {
                            accidentals.append(accidental)
                        }
                    }
                }
            }
        }
        
        return accidentals
    }
    
    private static func calculateRestDurations(beatNoteGrid: inout [[[(Note, Note.Accidental?)]?]]) -> [Note.Duration] {
        var restDurations: [Note.Duration] = []

        for column in beatNoteGrid {
            for row in column {
                if let notes = row {
                    for note in notes {
                        if note.0.isRest {
                            restDurations.append(note.0.duration)
                        }
                    }
                }
            }
        }
        
        return restDurations
    }
}

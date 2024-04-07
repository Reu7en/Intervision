//
//  BeamViewModel.swift
//  Intervision
//
//  Created by Reuben on 16/02/2024.
//

import Foundation
import SwiftUI

class BeamViewModel: ObservableObject {
    
    let beamGroups: [[Chord]]
    let noteGrid: [[[Note?]]]
    let beatGeometry: GeometryProxy
    let middleStaveNote: Note?
    let rows: Int
    let noteSize: CGFloat
    let beatIndex: Int
    
    var positions: [[[CGPoint]]] {
        calculatePositions()
    }
    
    var beamDirections: [Direction] {
        calculateBeamDirections()
    }
    
    var beamLines: [Line] {
        calculateBeamLines()
    }
    
    var stemLines: [Line] {
        calculateStemLines()
    }
    
    init(
        beamGroups: [[Chord]],
        noteGrid: [[[Note?]]],
        beatGeometry: GeometryProxy,
        middleStaveNote: Note?,
        rows: Int,
        noteSize: CGFloat,
        beatIndex: Int
    ) {
        self.beamGroups = beamGroups
        self.noteGrid = noteGrid
        self.beatGeometry = beatGeometry
        self.middleStaveNote = middleStaveNote
        self.rows = rows
        self.noteSize = noteSize
        self.beatIndex = beatIndex
    }
    
    private func calculatePositions() -> [[[CGPoint]]] {
        var positions: [[[CGPoint]]] = []
        
        for beamGroup in beamGroups {
            var groupPositions: [[CGPoint]] = []
            
            for chord in beamGroup {
                var chordPositions: [CGPoint] = []
                
                for note in chord.notes {
                    if let (rowIndex, columnIndex) = findNoteIndex(note) {
                        let notePosition =
                        BarViewModel.calculateNotePosition(
                            isRest: note.isRest,
                            rowIndex: rowIndex,
                            columnIndex: columnIndex,
                            totalRows: rows,
                            totalColumns: noteGrid[beatIndex][rowIndex].count,
                            geometry: beatGeometry
                        )
                        
                        if !note.isRest {
                            chordPositions.append(notePosition)
                        }
                    }
                }
                
                groupPositions.append(chordPositions)
            }
            
            positions.append(groupPositions)
        }
        
        return positions
    }
    
    private func calculateBeamDirections() -> [Direction] {
        var directions: [Direction] = []
        
        for chordGroup in beamGroups {
            var totalDistance = 0
            
            for chord in chordGroup {
                for note in chord.notes {
                    guard !note.isRest, let middleStaveNote = middleStaveNote else { continue }
                    totalDistance += middleStaveNote.calculateDistance(from: middleStaveNote, to: note)
                }
            }
            
            directions.append(totalDistance > 0 ? .Upward : .Downward)
        }
        
        return directions
    }
    
    private func findNoteIndex(_ note: Note) -> (rowIndex: Int, columnIndex: Int)? {
        for group in noteGrid {
            for (rowIndex, row) in group.enumerated() {
                for (columnIndex, gridNote) in row.enumerated() {
                    if let gridNote = gridNote {
                        if gridNote.id == note.id {
                            return (rowIndex, columnIndex)
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    private func calculateBeamLines() -> [Line] {
        return []
    }
    
    private func calculateStemLines() -> [Line] {
        return []
    }
    
    static func findFurthestPosition(in positions: [CGPoint], direction: Direction) -> CGPoint? {
        guard !positions.isEmpty else { return nil }
        
        switch direction {
        case .Upward:
            return positions.min(by: { $0.y < $1.y })
        case .Downward:
            return positions.max(by: { $0.y < $1.y })
        }
    }
    
    static func findMinimumPassThrough(in positions: [[CGPoint]], direction : Direction, stemLength: CGFloat) -> CGPoint? {
        if let furthestPosition = findFurthestPosition(in: positions.flatMap{ $0 }, direction: direction == .Upward ? .Downward : .Upward) {
            return CGPoint(x: furthestPosition.x, y: direction == .Upward ? furthestPosition.y - stemLength / 2 : furthestPosition.y + stemLength / 2)
        }
        
        return nil
    }
}

extension BeamViewModel {
    enum Direction {
        case Upward, Downward
    }
}

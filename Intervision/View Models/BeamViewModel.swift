//
//  BeamViewModel.swift
//  Intervision
//
//  Created by Reuben on 16/02/2024.
//

import Foundation
import SwiftUI

class BeamViewModel: ObservableObject {
    
    @Published var beamGroups: [[Chord]]
    @Published var positions: [[[CGPoint]]] = []
    @Published var beamDirections: [Direction] = []
    @Published var noteSize: CGFloat
    
    let noteGrid: [[Note?]]
    let geometry: GeometryProxy
    let beatGeometry: GeometryProxy
    let middleStaveNote: Note?
    let rows: Int
    
    init(beamGroups: [[Chord]], noteGrid: [[Note?]], geometry: GeometryProxy, beatGeometry: GeometryProxy, middleStaveNote: Note?, rows: Int, noteSize: CGFloat) {
        self.beamGroups = beamGroups
        self.noteGrid = noteGrid
        self.geometry = geometry
        self.beatGeometry = beatGeometry
        self.middleStaveNote = middleStaveNote
        self.rows = rows
        self.noteSize = noteSize
        
        calculatePositions()
        calculateBeamDirection()
    }
    
    func calculateBeamDirection() {
        var previousDirection: Direction? = nil
        
        for chordGroup in beamGroups {
            var totalDistance = 0
            var hasTie = false
            
            for chord in chordGroup {
                for note in chord.notes {
                    guard !note.isRest, let middleStaveNote = middleStaveNote else { continue }
                    totalDistance += middleStaveNote.calculateDistance(from: middleStaveNote, to: note)
                    if let tie = note.tie, tie == .Stop {
                        hasTie = true
                    }
                }
            }
            
            if hasTie, let direction = previousDirection {
                beamDirections.append(direction)
            } else {
                beamDirections.append(totalDistance > 0 ? .Upward : .Downward)
                previousDirection = totalDistance > 0 ? .Upward : .Downward
            }
        }
    }
    
    func calculatePositions() {
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
                            totalColumns: noteGrid[rowIndex].count,
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
    }

    private func findNoteIndex(_ note: Note) -> (rowIndex: Int, columnIndex: Int)? {
        for rowIndex in 0..<noteGrid.count {
            if let columnIndex = noteGrid[rowIndex].firstIndex(where: { $0 == note }) {
                return (rowIndex, columnIndex)
            }
        }
        
        return nil
    }
    
    func findFurthestPosition(in positions: [CGPoint], direction: BeamViewModel.Direction) -> CGPoint? {
        guard !positions.isEmpty else { return nil }
        
        switch direction {
        case .Upward:
            return positions.min(by: { $0.y < $1.y })
        case .Downward:
            return positions.max(by: { $0.y < $1.y })
        }
    }
}

extension BeamViewModel {
    enum Direction {
        case Upward, Downward
    }
}

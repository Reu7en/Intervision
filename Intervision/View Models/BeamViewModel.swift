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
    
    let noteGrid: [[[Note?]]]
    let geometry: GeometryProxy
    let beatGeometry: GeometryProxy
    let middleStaveNote: Note?
    let rows: Int
    let beatIndex: Int
    
    init(beamGroups: [[Chord]], noteGrid: [[[Note?]]], geometry: GeometryProxy, beatGeometry: GeometryProxy, middleStaveNote: Note?, rows: Int, noteSize: CGFloat, beatIndex: Int) {
        self.beamGroups = beamGroups
        self.noteGrid = noteGrid
        self.geometry = geometry
        self.beatGeometry = beatGeometry
        self.middleStaveNote = middleStaveNote
        self.rows = rows
        self.noteSize = noteSize
        self.beatIndex = beatIndex
        
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
            
            for (chordIndex, chord) in beamGroup.enumerated() {
                var chordPositions: [CGPoint] = []
                
                for note in chord.notes {
                    if let (rowIndex, columnIndex) = findNoteIndex(note) {
                        let notePosition =
                        BarViewModel.calculateNotePosition(
                            isRest: note.isRest,
                            rowIndex: rowIndex,
                            columnIndex: chordIndex,
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
    }

    private func findNoteIndex(_ note: Note) -> (rowIndex: Int, columnIndex: Int)? {
        for beam in noteGrid {
            for (rowIndex, row) in beam.enumerated() {
                if let columnIndex = row.firstIndex(where: { $0 == note }) {
                    return (rowIndex, columnIndex)
                }
            }
        }
        
        return nil
    }
    
    // Look at whole beam group, find furthest at x = 0 and furthest and furthest x value?
    func findFurthestPosition(in positions: [CGPoint], direction: BeamViewModel.Direction) -> CGPoint? {
        guard !positions.isEmpty else { return nil }
        
        switch direction {
        case .Upward:
            return positions.min(by: { $0.y < $1.y })
        case .Downward:
            return positions.max(by: { $0.y < $1.y })
        }
    }
    
    func findFurthestPositions(in positions: [[CGPoint]], direction: BeamViewModel.Direction) -> (CGPoint, CGPoint)? {
        guard !positions.isEmpty else { return nil }
        
        // Initialize variables to store furthest positions
        var furthestFirstPosition: CGPoint?
        var furthestSecondPosition: CGPoint?
        
        // Initialize variables to track lowest and highest x values
        var lowestX: CGFloat = .infinity
        var highestX: CGFloat = -.infinity
        
        // Find lowest and highest x values
        for position in positions {
            for point in position {
                if point.x < lowestX {
                    lowestX = point.x
                    furthestFirstPosition = point
                }
                if point.x > highestX {
                    highestX = point.x
                    furthestSecondPosition = point
                }
            }
        }
        
        // Check if furthestFirstPosition and furthestSecondPosition are nil
        guard let firstPosition = furthestFirstPosition, let secondPosition = furthestSecondPosition else {
            return nil
        }
        
        // Find the furthest positions based on direction
        switch direction {
        case .Upward:
            // Find points with lowest y value for the lowest and highest x values
            for position in positions {
                for point in position {
                    if point.x == lowestX && point.y < firstPosition.y {
                        furthestFirstPosition = point
                    }
                    if point.x == highestX && point.y < secondPosition.y {
                        furthestSecondPosition = point
                    }
                }
            }
        case .Downward:
            // Find points with highest y value for the lowest and highest x values
            for position in positions {
                for point in position {
                    if point.x == lowestX && point.y > firstPosition.y {
                        furthestFirstPosition = point
                    }
                    if point.x == highestX && point.y > secondPosition.y {
                        furthestSecondPosition = point
                    }
                }
            }
        }
        
        guard furthestFirstPosition != nil, furthestSecondPosition != nil else {
            return nil
        }
        
        // Return the furthest positions
        return (furthestFirstPosition!, furthestSecondPosition!)
    }
}

extension BeamViewModel {
    enum Direction {
        case Upward, Downward
    }
}

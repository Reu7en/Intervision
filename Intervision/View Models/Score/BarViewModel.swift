//
//  BarViewModel.swift
//  Intervision
//
//  Created by Reuben on 11/02/2024.
//

import Foundation
import SwiftUI

class BarViewModel: ObservableObject {
    
    let bar: Bar
    let gaps: Int
    let ledgerLines: Int
    let showClef: Bool
    let showKey: Bool
    let showTime: Bool
    
    var rows: Int {
        calculateRows()
    }
    
    var beats: Int {
        calculateBeats()
    }
    
    var beatValue: Double {
        calculateBeatValue()
    }
    
    var isBarRest: Bool {
        calculateIsBarRest()
    }
    
    var lowestGapNote: Note? {
        calculateLowestGapNote()
    }
    
    var middleStaveNote: Note? {
        calculateMiddleStaveNote()
    }
    
    var splitChords: [[Chord]] {
        calculateSplitChords()
    }
    
    var beamGroupChords: [[[Chord]]] {
        calculateBeamGroupChords()
    }
    
    var noteGrid: [[[Note?]]] {
        calculateNoteGrid()
    }
    
    init
    (
        bar: Bar,
        gaps: Int = 4,
        ledgerLines: Int = 3,
        showClef: Bool = false,
        showKey: Bool = false,
        showTime: Bool = false
    ) {
        self.bar = bar
        self.gaps = gaps
        self.ledgerLines = ledgerLines
        self.showClef = showClef
        self.showKey = showKey
        self.showTime = showTime
    }
}

// Functions
extension BarViewModel {
    private func calculateRows() -> Int {
        return ((self.gaps * 2) + 1) + 2 * ((self.ledgerLines * 2) + 1)
    }
    
    private func calculateBeats() -> Int {
        switch self.bar.timeSignature {
            case .common:
                return 4
            case .cut:
                return 2
            case .custom(let beats, _):
                return beats
        }
    }
    
    private func calculateBeatValue() -> Double {
        switch self.bar.timeSignature {
            case .common:
                return 0.25
            case .cut:
                return 0.5
            case .custom(_, let noteValue):
                return 1 / Double(noteValue)
        }
    }
    
    private func calculateIsBarRest() -> Bool {
        for chord in self.bar.chords {
            guard let firstNote = chord.notes.first else { return false }
            
            if firstNote.duration == Note.Duration.bar && firstNote.isRest {
                return true
            }
        }
        
        return self.bar.chords.isEmpty
    }
    
    private func calculateLowestGapNote() -> Note? {
        let lowestGapNote = Note(
            duration: .bar,
            durationValue: -1,
            isRest: false,
            isDotted: false,
            hasAccent: false
        )
        
        switch self.bar.clef {
            case .Treble:
                lowestGapNote.pitch = Note.Pitch.F
                lowestGapNote.octave = Note.Octave.oneLine
                
                return lowestGapNote
            case .Soprano:
                lowestGapNote.pitch = Note.Pitch.D
                lowestGapNote.octave = Note.Octave.oneLine
                
                return lowestGapNote
            case .Alto:
                lowestGapNote.pitch = Note.Pitch.F
                lowestGapNote.octave = Note.Octave.small
                
                return lowestGapNote
            case .Tenor:
                lowestGapNote.pitch = Note.Pitch.A
                lowestGapNote.octave = Note.Octave.small
                
                return lowestGapNote
            case .Bass:
                lowestGapNote.pitch = Note.Pitch.A
                lowestGapNote.octave = Note.Octave.great
                
                return lowestGapNote
            case .Neutral:
                return nil
        }
    }
    
    private func calculateMiddleStaveNote() -> Note? {
        guard let lowestGapNote = self.lowestGapNote,
              let lowestPitch = lowestGapNote.pitch,
              let lowestOctave = lowestGapNote.octave
        else { return nil }
        
        let middleStaveNote = Note(
            duration: .bar,
            durationValue: -1,
            isRest: false,
            isDotted: false,
            hasAccent: false
        )
        
        let middleNoteDistance = self.gaps - 1
        let totalPitchDistance = lowestPitch.distanceFromC() + (lowestOctave.rawValue * 7) + middleNoteDistance
        let pitchDistanceInOctave = totalPitchDistance % 7
        
        middleStaveNote.pitch = Note.Pitch.allCases[pitchDistanceInOctave]
        middleStaveNote.octave = Note.Octave(rawValue: totalPitchDistance / 7)
        
        return middleStaveNote
    }
    
    func calculateSplitChords() -> [[Chord]] {
        var splitChords: [[Chord]] = []
        var timeLeft: Double = beatValue
        var timeModificationTimeLeft: Double = 0
        var chordGroup: [Chord] = []
        let epsilon = 0.00001
        
        for chord in bar.chords {
            guard let duration = chord.notes.first?.duration.rawValue,
                  let isDotted = chord.notes.first?.isDotted
            else { return [] }
            
            let actualDuration = isDotted ? duration * 1.5 : duration
            
            if let timeModification = chord.notes.first?.timeModification {
                if case .custom(let actual, let normal, let normalType) = timeModification {
                    if abs(timeModificationTimeLeft) < epsilon {
                        timeModificationTimeLeft = Double(actual) * Double(normalType.rawValue)
                    }
                    
                    let actualTimeModificationDuration = actualDuration * (Double(normal) / Double(actual))
                    
                    chordGroup.append(chord)
                    timeLeft -= actualTimeModificationDuration
                    timeModificationTimeLeft -= actualDuration
                } else { return [] }
            } else {
                chordGroup.append(chord)
                timeLeft -= actualDuration
            }
            
            while timeLeft < 0 - epsilon {
                timeLeft += beatValue
            }
            
            if abs(timeLeft) < epsilon && abs(timeModificationTimeLeft) < epsilon {
                timeLeft = beatValue
                splitChords.append(chordGroup)
                chordGroup = []
            }
        }
        
        if !chordGroup.isEmpty {
            splitChords.append(chordGroup)
        }
        
        return splitChords
    }
    
    func calculateBeamGroupChords() -> [[[Chord]]] {
        var beamGroupChords: [[[Chord]]] = []
        
        for chordGroup in self.splitChords {
            var currentBeamGroup: [[Chord]] = []
            var currentStandardGroup: [Chord] = []
            var currentTimeModificationGroup: [Chord] = []
            
            for chord in chordGroup {
                if let firstNote = chord.notes.first, !firstNote.isRest {
                    let duration = firstNote.duration.rawValue
                    
                    if firstNote.timeModification != nil {
                        if !currentStandardGroup.isEmpty {
                            currentBeamGroup.append(currentStandardGroup)
                            currentStandardGroup = []
                        }
                        
                        currentTimeModificationGroup.append(chord)
                    } else {
                        if !currentTimeModificationGroup.isEmpty {
                            currentBeamGroup.append(currentTimeModificationGroup)
                            currentTimeModificationGroup = []
                        }
                        
                        if duration >= self.beatValue {
                            if !currentStandardGroup.isEmpty {
                                currentBeamGroup.append(currentStandardGroup)
                                currentStandardGroup = []
                            }
                            
                            currentBeamGroup.append([chord])
                        } else {
                            currentStandardGroup.append(chord)
                        }
                    }
                }
            }
            
            if !currentStandardGroup.isEmpty {
                currentBeamGroup.append(currentStandardGroup)
            }
            
            if !currentTimeModificationGroup.isEmpty {
                currentBeamGroup.append(currentTimeModificationGroup)
            }
            
            beamGroupChords.append(currentBeamGroup)
        }
        
        return beamGroupChords
    }

    /*
    func calculateNoteGrid() -> [[[Note?]]] {
        var noteGrid: [[[Note?]]] = []
        
        let gridRows = rows
        let lowestGapIndex = (ledgerLines * 2) + 2
            
        for (groupIndex, chordGroup) in self.splitChords.enumerated() {
            var groupGrid: [[Note?]] = Array(repeating: Array(repeating: nil, count: chordGroup.count), count: gridRows)
            
            for (chordIndex, chord) in chordGroup.enumerated() {
                for (noteIndex, note) in chord.notes.enumerated() {
                    if note.isRest {
                        groupGrid[0][chordIndex] = note
                    } else {
                        guard let distance = calculateGapBetweenLowestGapNote(note: note) else { continue }
                        var index = lowestGapIndex + distance
                        
                        if index < 0 {
                            self.splitChords[groupIndex][chordIndex].notes[noteIndex].increaseOctave()
                            index += 7
                        } else if index > gridRows - 1 {
                            self.splitChords[groupIndex][chordIndex].notes[noteIndex].decreaseOctave()
                            index -= 7
                        }
                        
                        if index < 0 || index > gridRows - 1 { continue }
                        
                        groupGrid[gridRows - 1 - index][chordIndex] = self.splitChords[groupIndex][chordIndex].notes[noteIndex]
                    }
                }
            }
            
            noteGrid.append(groupGrid)
        }
     
        return noteGrid
    }
     */
    
    func calculateNoteGrid() -> [[[Note?]]] {
        var noteGrid: [[[Note?]]] = []
        let lowestGapIndex = (self.ledgerLines * 2) + 2
        
        for chordGroup in self.splitChords {
            var groupGrid: [[Note?]] = Array(repeating: Array(repeating: nil, count: self.rows), count: chordGroup.count)
            
            for (chordIndex, chord) in chordGroup.enumerated() {
                for note in chord.notes {
                    if note.isRest {
                        groupGrid[chordIndex][0] = note
                    } else {
                        guard let distance = calculateGapBetweenLowestGapNote(note: note) else {
                            for i in 0..<groupGrid[chordIndex].count {
                                if groupGrid[chordIndex][i] == nil {
                                    groupGrid[chordIndex][0] = note
                                }
                            }
                            
                            continue
                        }
                        
                        var index = lowestGapIndex + distance + 1
                        
                        while index <= 0 {
                            note.increaseOctave()
                            index += 7
                            
                            while groupGrid[chordIndex].indices.contains(index) && groupGrid[chordIndex][self.rows - index] != nil {
                                note.increaseOctave()
                                index += 7
                            }
                        }
                        
                        while index > self.rows {
                            note.decreaseOctave()
                            index -= 7
                            
                            while groupGrid[chordIndex].indices.contains(index) && groupGrid[chordIndex][self.rows - index] != nil {
                                note.decreaseOctave()
                                index -= 7
                            }
                        }
                        
                        if groupGrid[chordIndex][self.rows - index] == nil {
                            groupGrid[chordIndex][self.rows - index] = note
                        } else {
                            for i in 0..<groupGrid[chordIndex].count {
                                if groupGrid[chordIndex][i] == nil {
                                    groupGrid[chordIndex][0] = note
                                }
                            }
                        }
                    }
                }
            }
            
            noteGrid.append(groupGrid)
        }
        
        return noteGrid
    }
    
    private func calculateGapBetweenLowestGapNote(note: Note) -> Int? {
        if let lowest = self.lowestGapNote,
           let lowestPitch = lowest.pitch,
           let notePitch = note.pitch,
           let lowestOctave = lowest.octave,
           let noteOctave = note.octave {
            var distance = notePitch.distanceFromC() - lowestPitch.distanceFromC()
            
            if lowestOctave != noteOctave {
                distance += (noteOctave.rawValue - lowestOctave.rawValue) * 7
            }
            
            return distance
        }
        
        return nil
    }
    
    // must check if accidental already rendered in bar
    func shouldRenderAccidental(_ note: Note) -> Note.Accidental? {
        guard let pitch = note.pitch else {
            return nil
        }
        
        if let alteredNote = bar.keySignature.alteredNotes.first(where: { $0.0 == pitch }) {
            if alteredNote.1 == note.accidental {
                return nil
            } else {
                if note.accidental == nil {
                    return .Natural
                } else {
                    return note.accidental
                }
            }
        }
        
        return note.accidental
    }
    
    static func calculateNotePosition(isRest: Bool, rowIndex: Int, columnIndex: Int, totalRows: Int, totalColumns: Int, geometry: GeometryProxy) -> CGPoint {
        let xPosition = (totalColumns == 1) ? 0 : (geometry.size.width / CGFloat(totalColumns - 1)) * CGFloat(columnIndex)
        let yPosition = isRest ? geometry.size.height / 2 : (geometry.size.height / CGFloat(totalRows - 1)) * CGFloat(rowIndex)
        
        return CGPoint(x: xPosition, y: yPosition)
    }
    
//    static func calculateNotePositions(chords: [Chord])
}

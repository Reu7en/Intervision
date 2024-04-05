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
    
    var beatSplitChords: [[Chord]] {
        calculateBeatSplitChords()
    }
    
    var beamSplitChords: [[[Chord]]] {
        calculateBeamSplitChords()
    }
    
    var noteGrid: [[[Note?]]] {
        calculateNoteGrid()
    }
    
    init(
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
    func calculateBeats() -> Int {
        switch self.bar.timeSignature {
            case .common:
                return 4
            case .cut:
                return 2
            case .custom(let beats, _):
                return beats
        }
    }
    
    func calculateBeatValue() -> Double {
        switch self.bar.timeSignature {
            case .common:
                return 0.25
            case .cut:
                return 0.5
            case .custom(_, let noteValue):
                return 1 / Double(noteValue)
        }
    }
    
    func calculateRows() -> Int {
        return ((self.gaps * 2) + 1) + 2 * ((self.ledgerLines * 2) + 1)
    }
    
    func calculateLowestGapNote() -> Note? {
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
    
    func calculateIsBarRest() -> Bool {
        for chord in self.bar.chords {
            guard let firstNote = chord.notes.first else { return false }
            
            if firstNote.duration == Note.Duration.bar && firstNote.isRest {
                return true
            }
        }
        
        return self.bar.chords.isEmpty
    }
    
    func calculateMiddleStaveNote() -> Note? {
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
        
        let middleNoteDistance = gaps - 1
        let totalPitchDistance = lowestPitch.distanceFromC() + (lowestOctave.rawValue * 7) + middleNoteDistance
        let pitchDistanceInOctave = totalPitchDistance % 7
        
        middleStaveNote.pitch = Note.Pitch.allCases[pitchDistanceInOctave]
        middleStaveNote.octave = Note.Octave(rawValue: totalPitchDistance / 7)
        
        return middleStaveNote
    }
    
    func calculateBeatSplitChords() -> [[Chord]] {
        var beatSplitChords: [[Chord]] = []
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
            
            while timeLeft < 0 {
                timeLeft += beatValue
            }
            
//            if timeModification == nil {
//                if actualDuration <= timeLeft {
//                    chordGroup.append(chord)
//                    timeLeft -= actualDuration
//                } else {
//                    timeLeft = beatValue
//                    
//                    if !chordGroup.isEmpty {
//                        beatSplitChords.append(chordGroup)
//                        chordGroup = []
//                    }
//                    
//                    chordGroup.append(chord)
//                    timeLeft -= actualDuration
//                }
//            } else {
//                chordGroup.append(chord)
//                
//                if case .custom(let actual, let normal) = chord.notes.first?.timeModification {
//                    if let duration = chord.notes.first?.duration.rawValue {
//                        let actualDuration = duration * (Double(normal) / Double(actual))
//                        timeLeft -= actualDuration
//                    } else { return [] }
//                } else { return [] }
//            }
            
            if abs(timeLeft) < epsilon && abs(timeModificationTimeLeft) < epsilon {
                timeLeft = beatValue
                beatSplitChords.append(chordGroup)
                chordGroup = []
            }
        }
        
        if !chordGroup.isEmpty {
            beatSplitChords.append(chordGroup)
        }
        
        return beatSplitChords
    }
    
    func calculateBeamSplitChords() -> [[[Chord]]] {
        var beamSplitChords: [[[Chord]]] = []
        
        for chordGroup in self.beatSplitChords {
            var beamGroup: [[Chord]] = []
            var standardGroup: [Chord] = []
            var timeModificationGroup: [Chord] = []
            
            for chord in chordGroup {
                if chord.notes.first?.timeModification != nil {
                    if !standardGroup.isEmpty {
                        beamGroup.append(standardGroup)
                        standardGroup = []
                    }
                    
                    timeModificationGroup.append(chord)
                } else {
                    if !timeModificationGroup.isEmpty {
                        beamGroup.append(timeModificationGroup)
                        timeModificationGroup = []
                    }
                    
                    standardGroup.append(chord)
                }
            }
            
            if !standardGroup.isEmpty {
                beamGroup.append(standardGroup)
            }
            
            if !timeModificationGroup.isEmpty {
                beamGroup.append(timeModificationGroup)
            }
            
            beamSplitChords.append(beamGroup)
        }

        return beamSplitChords
    }

    func calculateNoteGrid() -> [[[Note?]]] {
        var noteGrid: [[[Note?]]] = []
        
        let gridRows = rows
            let lowestGapIndex = (ledgerLines * 2) + 2
            
        for (groupIndex, chordGroup) in self.beatSplitChords.enumerated() {
                var groupGrid: [[Note?]] = Array(repeating: Array(repeating: nil, count: chordGroup.count), count: gridRows)
                
                for (chordIndex, chord) in chordGroup.enumerated() {
                    for (noteIndex, note) in chord.notes.enumerated() {
                        if note.isRest {
                            groupGrid[0][chordIndex] = note
                        } else {
                            guard let distance = calculateGapBetweenLowestGapNote(note: note) else { continue }
                            var index = lowestGapIndex + distance
                            
                            if index < 0 {
                                self.beatSplitChords[groupIndex][chordIndex].notes[noteIndex].increaseOctave()
                                index += 7
                            } else if index > gridRows - 1 {
                                self.beatSplitChords[groupIndex][chordIndex].notes[noteIndex].decreaseOctave()
                                index -= 7
                            }
                            
                            if index < 0 || index > gridRows - 1 { continue }
                            
                            groupGrid[gridRows - 1 - index][chordIndex] = self.beatSplitChords[groupIndex][chordIndex].notes[noteIndex]
                        }
                    }
                }
                
                noteGrid.append(groupGrid)
            }
        
        return noteGrid
    }
    
    func calculateGapBetweenLowestGapNote(note: Note) -> Int? {
        var distance: Int?
        
        if let lowest = lowestGapNote,
           let lowestPitch = lowest.pitch,
           let notePitch = note.pitch,
           let lowestOctave = lowest.octave,
           let noteOctave = note.octave {
            distance = notePitch.distanceFromC() - lowestPitch.distanceFromC()
            
            if lowestOctave != noteOctave {
                distance! += (noteOctave.rawValue - lowestOctave.rawValue) * 7
            }
        }
        
        return distance
    }
    
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
}

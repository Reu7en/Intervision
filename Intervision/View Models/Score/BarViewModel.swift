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
    let showName: Bool
    let partName: String
    
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
    
    var noteGrid: [[[[Note]?]]] {
        calculateNoteGrid()
    }
    
    init
    (
        bar: Bar,
        gaps: Int = 4,
        ledgerLines: Int = 4,
        showClef: Bool = false,
        showKey: Bool = false,
        showTime: Bool = false,
        showName: Bool = false,
        partName: String = ""
    ) {
        self.bar = bar
        self.gaps = gaps
        self.ledgerLines = ledgerLines
        self.showClef = showClef
        self.showKey = showKey
        self.showTime = showTime
        self.showName = showName
        self.partName = partName
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
        if self.bar.chords.isEmpty {
            return true
        }
        
        for chord in self.bar.chords {
            guard let firstNote = chord.notes.first else { return true }
            
            if firstNote.duration == Note.Duration.bar && firstNote.isRest {
                return true
            }
        }
        
        return false
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
    
    private func calculateSplitChords() -> [[Chord]] {
        var splitChords: [[Chord]] = []
        var timeLeft: Double = beatValue
        var timeModificationTimeLeft: Double = 0
        var chordGroup: [Chord] = []
        let epsilon = 0.00001
        
        for chord in self.bar.chords {
            guard let duration = chord.notes.first?.duration.rawValue,
                  let isDotted = chord.notes.first?.isDotted
            else { return [] }
            
            let actualDuration = isDotted ? duration * 1.5 : duration
            
            if let timeModification = chord.notes.first?.timeModification {
                if case .custom(let actual, let normal, let normalDuration) = timeModification {
                    if abs(timeModificationTimeLeft) < epsilon {
                        timeModificationTimeLeft = Double(actual) * Double(normalDuration.rawValue)
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
            
            while timeLeft < -epsilon {
                timeLeft += self.beatValue
            }
            
            if abs(timeLeft) < epsilon && abs(timeModificationTimeLeft) < epsilon {
                timeLeft = self.beatValue
                splitChords.append(chordGroup)
                chordGroup = []
            }
        }
        
        if !chordGroup.isEmpty {
            splitChords.append(chordGroup)
        }
        
        return splitChords
    }
    
    private func calculateBeamGroupChords() -> [[[Chord]]] {
        var beamGroupChords: [[[Chord]]] = []
        
        for chordGroup in self.splitChords {
            var currentBeamGroup: [[Chord]] = []
            var currentStandardGroup: [Chord] = []
            var currentTimeModificationGroup: [Chord] = []
            
            for chord in chordGroup {
                if let firstNote = chord.notes.first {
                    if firstNote.isRest {
                        if !currentStandardGroup.isEmpty {
                            let splitStandardGroups = splitStandardGroup(currentStandardGroup)
                            
                            for standardGroup in splitStandardGroups {
                                if !standardGroup.isEmpty {
                                    currentBeamGroup.append(standardGroup)
                                }
                            }
                            
                            currentStandardGroup = []
                        }
                    } else {
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
                            
                            if firstNote.duration.rawValue >= self.beatValue {
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
            }
            
            if !currentStandardGroup.isEmpty {
                let splitStandardGroups = splitStandardGroup(currentStandardGroup)
                
                for standardGroup in splitStandardGroups {
                    if !standardGroup.isEmpty {
                        currentBeamGroup.append(standardGroup)
                    }
                }
            }
            
            if !currentTimeModificationGroup.isEmpty {
                currentBeamGroup.append(currentTimeModificationGroup)
            }
            
            beamGroupChords.append(currentBeamGroup)
        }
        
        return beamGroupChords
    }
    
    private func splitStandardGroup(_ group: [Chord]) -> [[Chord]] {
        if group.count <= 4 {
            return [group]
        }
        
        var standardGroupTargetDuration = Note.Duration.quarter.rawValue
        var standardGroupActualDuration: Double = 0
        
        for chord in group {
            if let firstNote = chord.notes.first {
                standardGroupActualDuration += firstNote.duration.rawValue
                
                if firstNote.duration == .thirtySecond {
                    standardGroupTargetDuration = Note.Duration.eighth.rawValue
                } else if firstNote.duration == .sixtyFourth {
                    standardGroupTargetDuration = Note.Duration.sixteenth.rawValue
                }
            }
        }
        
        if standardGroupTargetDuration == Note.Duration.quarter.rawValue {
            return [group]
        }
        
        var groups: [[Chord]] = Array(repeating: [], count: Int(standardGroupActualDuration / standardGroupTargetDuration))
        var timeLeft = standardGroupTargetDuration
        var currentIndex = 0
        
        for chord in group {
            if let firstNote = chord.notes.first, groups.indices.contains(currentIndex) {
                if firstNote.duration.rawValue > timeLeft {
                    timeLeft += firstNote.duration.rawValue
                    groups.append([])
                    currentIndex += 1
                }
                
                groups[currentIndex].append(chord)
                timeLeft -= firstNote.duration.rawValue
                
                if timeLeft == 0 {
                    timeLeft = standardGroupTargetDuration
                    currentIndex += 1
                }
            }
        }
        
        return groups
    }
    
    private func calculateNoteGrid() -> [[[[Note]?]]] {
        var noteGrid: [[[[Note]?]]] = []
        let lowestGapIndex = (self.ledgerLines * 2) + (self.gaps * 2)
        
        for chordGroup in self.splitChords {
            var groupGrid: [[[Note]?]] = Array(repeating: Array(repeating: nil, count: self.rows), count: chordGroup.count)
            
            for (chordIndex, chord) in chordGroup.enumerated() {
                for note in chord.notes {
                    if note.isRest {
                        if groupGrid[chordIndex][0] == nil {
                            groupGrid[chordIndex][0] = [note]
                        } else {
                            groupGrid[chordIndex][0]?.append(note)
                        }
                    } else {
                        guard let distance = calculateGapBetweenLowestGapNote(note) else {
                            let rest = Note(
                                duration: note.duration,
                                durationValue: -1,
                                isRest: true,
                                isDotted: note.isDotted,
                                hasAccent: false
                            )
                            
                            if groupGrid[chordIndex][0] == nil {
                                groupGrid[chordIndex][0] = [rest]
                            } else {
                                groupGrid[chordIndex][0]?.append(rest)
                            }
                            
                            continue
                        }
                        
                        var index = lowestGapIndex - distance
                        
                        if index < 0 {
                            note.decreaseOctave()
                            index += 7
                        }
                        
                        if index > self.rows - 1 {
                            note.increaseOctave()
                            index -= 7
                        }
                        
                        if index < 0 || index > self.rows - 1 {
                            let rest = Note(
                                duration: note.duration,
                                durationValue: -1,
                                isRest: true,
                                isDotted: note.isDotted,
                                hasAccent: false
                            )
                            
                            if groupGrid[chordIndex][0] == nil {
                                groupGrid[chordIndex][0] = [rest]
                            } else {
                                groupGrid[chordIndex][0]?.append(rest)
                            }
                            
                            continue
                        }
                        
                        if groupGrid[chordIndex][index] == nil {
                            groupGrid[chordIndex][index] = [note]
                        } else {
                            groupGrid[chordIndex][index]?.append(note)
                        }
                    }
                }
            }
            
            noteGrid.append(groupGrid)
        }
        
        return noteGrid
    }
    
    private func calculateGapBetweenLowestGapNote(_ note: Note) -> Int? {
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
}

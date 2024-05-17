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
    
    let rows: Int
    let beats: Int
    let beatValue: Double
    let isBarRest: Bool
    let lowestGapNote: Note?
    let middleStaveNote: Note?
    var splitChords: [[Chord]]
    let beamGroupChords: [[[Chord]]]
    var noteGrid: [[[[(Note, Note.Accidental?)]?]]]
    
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
        
        self.rows = BarViewModel.calculateRows(gaps: self.gaps, ledgerLines: self.ledgerLines)
        self.beats = BarViewModel.calculateBeats(timeSignature: self.bar.timeSignature)
        self.beatValue = BarViewModel.calculateBeatValue(timeSignature: self.bar.timeSignature)
        self.isBarRest = BarViewModel.calculateIsBarRest(chords: &self.bar.chords)
        self.lowestGapNote = BarViewModel.calculateLowestGapNote(clef: self.bar.clef)
        self.middleStaveNote = BarViewModel.calculateMiddleStaveNote(lowestGapNote: self.lowestGapNote, gaps: self.gaps)
        self.splitChords = BarViewModel.calculateSplitChords(beatValue: self.beatValue, chords: &self.bar.chords)
        self.beamGroupChords = BarViewModel.calculateBeamGroupChords(beatValue: self.beatValue, splitChords: &splitChords)
        self.noteGrid = BarViewModel.calculateNoteGrid(gaps: self.gaps, ledgerLines: self.ledgerLines, rows: self.rows, lowestGapNote: self.lowestGapNote, splitChords: &splitChords, bar: self.bar)
    }
}

// Functions
extension BarViewModel {
    private static func calculateRows(gaps: Int, ledgerLines: Int) -> Int {
        return ((gaps * 2) + 1) + 2 * ((ledgerLines * 2) + 1)
    }
    
    private static func calculateBeats(timeSignature: Bar.TimeSignature) -> Int {
        switch timeSignature {
            case .common:
                return 4
            case .cut:
                return 2
            case .custom(let beats, _):
                return beats
        }
    }
    
    private static func calculateBeatValue(timeSignature: Bar.TimeSignature) -> Double {
        switch timeSignature {
            case .common:
                return 0.25
            case .cut:
                return 0.5
            case .custom(_, let noteValue):
                return 1 / Double(noteValue)
        }
    }
    
    private static func calculateIsBarRest(chords: inout [Chord]) -> Bool {
        if chords.isEmpty {
            return true
        }
        
        for chord in chords {
            guard let firstNote = chord.notes.first else { return true }
            
            if firstNote.duration == Note.Duration.bar && firstNote.isRest {
                return true
            }
        }
        
        return false
    }
    
    private static func calculateLowestGapNote(clef: Bar.Clef) -> Note? {
        let lowestGapNote = Note(
            duration: .bar,
            isRest: false,
            isDotted: false,
            hasAccent: false
        )
        
        switch clef {
            case .Treble:
                lowestGapNote.pitch = Note.Pitch.F
                lowestGapNote.octave = Note.Octave.oneLine
                
                return lowestGapNote
            case .Soprano:
                lowestGapNote.pitch = Note.Pitch.D
                lowestGapNote.octave = Note.Octave.oneLine
                
                return lowestGapNote
            case .Alto:
                lowestGapNote.pitch = Note.Pitch.G
                lowestGapNote.octave = Note.Octave.small
                
                return lowestGapNote
            case .Tenor:
                lowestGapNote.pitch = Note.Pitch.E
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
    
    private static func calculateMiddleStaveNote(lowestGapNote: Note?, gaps: Int) -> Note? {
        guard let lowestGapNote = lowestGapNote,
              let lowestPitch = lowestGapNote.pitch,
              let lowestOctave = lowestGapNote.octave
        else { return nil }
        
        let middleStaveNote = Note(
            duration: .bar,
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
    
    private static func calculateSplitChords(beatValue: Double, chords: inout [Chord]) -> [[Chord]] {
        var splitChords: [[Chord]] = []
        var timeLeft: Double = beatValue
        var timeModificationTimeLeft: Double = 0
        var chordGroup: [Chord] = []
        let epsilon = 0.00001
        
        for chord in chords {
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
    
    private static func calculateBeamGroupChords(beatValue: Double, splitChords: inout [[Chord]]) -> [[[Chord]]] {
        var beamGroupChords: [[[Chord]]] = []
        
        for chordGroup in splitChords {
            var currentBeamGroup: [[Chord]] = []
            var currentStandardGroup: [Chord] = []
            var currentTimeModificationGroup: [Chord] = []
            
            for chord in chordGroup {
                if let firstNote = chord.notes.first {
                    if firstNote.isRest {
                        if !currentStandardGroup.isEmpty {
                            let splitStandardGroups = BarViewModel.splitStandardGroup(&currentStandardGroup)
                            
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
                            
                            if firstNote.duration.rawValue >= beatValue {
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
                let splitStandardGroups = splitStandardGroup(&currentStandardGroup)
                
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
    
    private static func splitStandardGroup(_ group: inout [Chord]) -> [[Chord]] {
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
    
    private static func calculateNoteGrid(gaps: Int, ledgerLines: Int, rows: Int, lowestGapNote: Note?, splitChords: inout [[Chord]], bar: Bar) -> [[[[(Note, Note.Accidental?)]?]]] {
        var noteGrid: [[[[(Note, Note.Accidental?)]?]]] = []
        var seenTones: [String: Note.Accidental?] = [:]
        let lowestGapIndex = (ledgerLines * 2) + (gaps * 2)
        
        for chordGroup in splitChords {
            var groupGrid: [[[(Note, Note.Accidental?)]?]] = Array(repeating: Array(repeating: nil, count: rows), count: chordGroup.count)
            
            for (chordIndex, chord) in chordGroup.enumerated() {
                for note in chord.notes {
                    if note.isRest {
                        if groupGrid[chordIndex][0] == nil {
                            groupGrid[chordIndex][0] = [(note, nil)]
                        } else {
                            groupGrid[chordIndex][0]?.append((note, nil))
                        }
                    } else {
                        guard let distance = calculateGapBetweenLowestGapNote(note, lowestGapNote: lowestGapNote) else {
                            let rest = Note(
                                duration: note.duration,
                                isRest: true,
                                isDotted: note.isDotted,
                                hasAccent: false
                            )
                            
                            if groupGrid[chordIndex][0] == nil {
                                groupGrid[chordIndex][0] = [(rest, nil)]
                            } else {
                                groupGrid[chordIndex][0]?.append((rest, nil))
                            }
                            
                            continue
                        }
                        
                        var index = lowestGapIndex - distance
                        
                        if index < 0 {
                            note.decreaseOctave()
                            index += 7
                        }
                        
                        if index > rows - 1 {
                            note.increaseOctave()
                            index -= 7
                        }
                        
                        if index < 0 || index > rows - 1 {
                            let rest = Note(
                                duration: note.duration,
                                isRest: true,
                                isDotted: note.isDotted,
                                hasAccent: false
                            )
                            
                            if groupGrid[chordIndex][0] == nil {
                                groupGrid[chordIndex][0] = [(rest, nil)]
                            } else {
                                groupGrid[chordIndex][0]?.append((rest, nil))
                            }
                            
                            continue
                        }
                        
                        let accidentalToRender: Note.Accidental? = {
                            let noteKey = getNoteKey(note: note)

                            if let lastAccidental = seenTones[noteKey] {
                                if note.accidental == lastAccidental {
                                    return nil
                                } else {
                                    seenTones[noteKey] = note.accidental ?? .Natural
                                    
                                    return note.accidental ?? .Natural
                                }
                            }

                            seenTones[noteKey] = note.accidental

                            return BarViewModel.calculateAccidentalToRender(bar: bar, note: note)
                        }()
                        
                        if groupGrid[chordIndex][index] == nil {
                            groupGrid[chordIndex][index] = [(note, accidentalToRender)]
                        } else {
                            groupGrid[chordIndex][index]?.append((note, accidentalToRender))
                        }
                    }
                }
            }
            
            noteGrid.append(groupGrid)
        }
        
        return noteGrid
    }
    
    private static func calculateGapBetweenLowestGapNote(_ note: Note, lowestGapNote: Note?) -> Int? {
        if let lowest = lowestGapNote,
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
    
    private static func calculateAccidentalToRender(bar: Bar, note: Note) -> Note.Accidental? {
        if bar.keySignature.alteredNotes.contains(where: { $0 == (note.pitch, note.accidental) }) { return nil }
        
        for alteredNote in bar.keySignature.alteredNotes {
            if note.pitch == alteredNote.0 {
                return note.accidental ?? .Natural
            }
        }
        
        return note.accidental
    }
    
    private static func getNoteKey(note: Note) -> String {
        guard let pitch = note.pitch, let octave = note.octave else { return "" }
        
        return "\(pitch.rawValue)_\(octave.rawValue)"
    }
}

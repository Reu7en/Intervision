//
//  BarViewModel.swift
//  Intervision
//
//  Created by Reuben on 11/02/2024.
//

import Foundation

class BarViewModel: ObservableObject {
    
    @Published var bar: Bar
    @Published var gaps: Int
    @Published var step: Step
    @Published var ledgerLines: Int
    @Published var isBarRest: Bool?
    @Published var beats: Int?
    @Published var beatValue: Double?
    @Published var rows: Int?
    @Published var lowestGapNote: Note?
    @Published var beatSplitChords: [[Chord]]
    @Published var noteGrid: [[Note?]]?
    
    init(bar: Bar, gaps: Int = 4, step: Step = Step.Tone, ledgerLines: Int = 3) {
        self.bar = bar
        self.gaps = gaps
        self.step = step
        self.ledgerLines = ledgerLines
        self.beatSplitChords = [[Chord]]()
        
        calculateIsBarRest()
        calculateBeats()
        calculateBeatValue()
        calculateRows()
        calculateLowestGapNote()
        
        if !splitChords() {
            isBarRest = true
        }
        
        
    }
}

// Functions
extension BarViewModel {
    func calculateBeats() {
        switch bar.timeSignature {
        case .common:
            self.beats = 4
            break
        case .cut:
            self.beats = 2
            break
        case .custom(let beats, _):
            self.beats = beats
            break
        }
    }
    
    func calculateBeatValue() {
        switch bar.timeSignature {
        case .common:
            self.beatValue = 0.25
            break
        case .cut:
            self.beatValue = 0.5
            break
        case .custom(_, let noteValue):
            self.beatValue = 1 / Double(noteValue)
            break
        }
    }
    
    func calculateRows() {
        self.rows = ((gaps * 2) + 1) + 2 * ((ledgerLines * 2) + 1)
    }
    
    func calculateLowestGapNote() {
        var note = Note(
            pitch: nil,
            accidental: nil,
            octave: nil,
            duration: Note.Duration.bar,
            durationValue: 0,
            timeModification: nil,
            dynamic: nil,
            graceNotes: nil,
            tie: nil,
            isRest: false,
            isDotted: false,
            hasAccent: false
        )
        
        switch bar.clef {
        case .Treble:
            note.pitch = Note.Pitch.F
            note.octave = Note.Octave.oneLine
            break
        case .Soprano:
            note.pitch = Note.Pitch.D
            note.octave = Note.Octave.oneLine
            break
        case .Alto:
            note.pitch = Note.Pitch.F
            note.octave = Note.Octave.small
            break
        case .Tenor:
            note.pitch = Note.Pitch.A
            note.octave = Note.Octave.small
            break
        case .Bass:
            note.pitch = Note.Pitch.A
            note.octave = Note.Octave.great
            break
        case .Neutral:
            break
        }
        
        self.lowestGapNote = note
    }
    
    func calculateIsBarRest() {
        if bar.chords.isEmpty {
            self.isBarRest = true
        }
        
        for chord in bar.chords {
            if chord.notes.first?.duration == Note.Duration.bar && chord.notes.first?.isRest == true {
                self.isBarRest = true
            }
        }
    }
    
    func splitChords() -> Bool {
        var timeLeft: Double = beatValue ?? -1
        var chordGroup: [Chord] = [Chord]()
        
        for chord in bar.chords {
            if timeLeft == -1 { return false }
            
            if let duration = chord.notes.first?.duration.rawValue,
               let isDotted = chord.notes.first?.isDotted {
                let actualDuration = isDotted ? duration * 1.5 : duration
                let timeModification = chord.notes.first?.timeModification
                
                if timeModification == nil {
                    if actualDuration <= timeLeft {
                        chordGroup.append(chord)
                        timeLeft -= actualDuration
                    } else {
                        let newDurationRaw = timeLeft
                        let carryDurationRaw = actualDuration - newDurationRaw
                        var newDuration: Note.Duration?
                        var carryDuration: Note.Duration?
                        var newDotted: Bool = false
                        var carryDotted: Bool = false
                        
                        if let duration = Note.Duration.init(rawValue: newDurationRaw) {
                            newDuration = duration
                        } else if let duration = Note.Duration.init(rawValue: newDurationRaw / 1.5) {
                            newDuration = duration
                            newDotted = true
                        } else { return false }
                        
                        if let duration = Note.Duration.init(rawValue: carryDurationRaw) {
                            carryDuration = duration
                        } else if let duration = Note.Duration.init(rawValue: carryDurationRaw / 1.5) {
                            carryDuration = duration
                            carryDotted = true
                        } else { return false }
                        
                        var newChord = Chord(notes: [])
                        var newCarry = Chord(notes: [])
                        
                        for note in chord.notes {
                            newChord.notes.append(Note(pitch: note.pitch, accidental: note.accidental, octave: note.octave, duration: newDuration!, durationValue: note.durationValue * (Double(newDuration!.rawValue) / Double(note.duration.rawValue)), timeModification: note.timeModification, dynamic: note.dynamic, graceNotes: note.graceNotes, tie: Note.Tie.Start, isRest: note.isRest, isDotted: newDotted, hasAccent: note.hasAccent))
                            newCarry.notes.append(Note(pitch: note.pitch, accidental: note.accidental, octave: note.octave, duration: carryDuration!, durationValue: note.durationValue * (Double(carryDuration!.rawValue) / Double(note.duration.rawValue)), timeModification: note.timeModification, dynamic: note.dynamic, graceNotes: note.graceNotes, tie: Note.Tie.Stop, isRest: note.isRest, isDotted: carryDotted, hasAccent: note.hasAccent))
                        }
                        
                        chordGroup.append(newChord)
                        beatSplitChords.append(chordGroup)
                        chordGroup = [Chord]()
                        chordGroup.append(newCarry)
                        timeLeft = beatValue ?? -1
                        timeLeft -= carryDurationRaw
                    }
                } else {
                    chordGroup.append(chord)
                    
                    if case .custom(let actual, let normal) = chord.notes.first?.timeModification {
                        if let duration = chord.notes.first?.duration.rawValue {
                            let actualDuration = duration * (Double(normal) / Double(actual))
                            timeLeft -= actualDuration
                        } else { return false }
                    } else { return false }
                }
                
                let epsilon = 0.00001
                
                if abs(timeLeft) < epsilon {
                    timeLeft = beatValue ?? -1
                    beatSplitChords.append(chordGroup)
                    chordGroup = [Chord]()
                }
            } else { return false }
        }
        
        return true
    }
    
    func populateNoteGrid() {
        if let gridColumns = beats,
           let gridRows = rows {
            noteGrid = Array(repeating: Array(repeating: nil, count: gridColumns), count: gridRows)
            
            for (beatIndex, beatChords) in beatSplitChords.enumerated() {
                for chord in beatChords {
                    for note in chord.notes {
                        
                    }
                }
            }
        } else { return }
    }
    
    // fix
    func shouldRenderAccidental(_ note: Note) -> Bool {
        if let pitch = note.pitch,
           let accidental = note.accidental {
            for alteredNote in bar.keySignature.alteredNotes {
                return alteredNote == (pitch, accidental)
            }
        }
        
        return true
    }
}

// Types
extension BarViewModel {
    enum Step {
        case Tone, Semitone
    }
}

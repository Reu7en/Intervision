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
    @Published var isBarRest: Bool = false
    @Published var beats: Int?
    @Published var beatValue: Double?
    @Published var rows: Int?
    @Published var lowestGapNote: Note?
    @Published var beatSplitChords: [[Chord]]
    @Published var beatSplitNoteGrid: [[[Note?]]] = [[[Note?]]]()
    @Published var beamSplitChords: [[Chord]]
    @Published var beamSplitNoteGrid: [[[Note?]]] = [[[Note?]]]()
    
    init(bar: Bar, gaps: Int = 4, step: Step = Step.Tone, ledgerLines: Int = 3) {
        self.bar = bar
        self.gaps = gaps
        self.step = step
        self.ledgerLines = ledgerLines
        self.beatSplitChords = [[Chord]]()
        self.beamSplitChords = [[Chord]]()
        
        calculateIsBarRest()
        calculateBeats()
        calculateBeatValue()
        calculateRows()
        calculateLowestGapNote()
        
        if !splitChordsIntoBeats() || !splitChordsIntoBeams() {
            isBarRest = true
        }
        
        if !populateNoteGrid(splitChords: &beatSplitChords, noteGrid: &beatSplitNoteGrid) || !populateNoteGrid(splitChords: &beamSplitChords, noteGrid: &beamSplitNoteGrid) {
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
    
    func splitChordsIntoBeats() -> Bool {
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
                            newChord.notes.append(
                                Note(
                                    pitch: note.pitch,
                                    accidental: note.accidental,
                                    octave: note.octave,
                                    duration: newDuration!,
                                    durationValue: note.durationValue * (Double(newDuration!.rawValue) / Double(note.duration.rawValue)),
                                    timeModification: note.timeModification,
                                    dynamic: note.dynamic,
                                    graceNotes: note.graceNotes,
                                    tie: Note.Tie.Start,
                                    isRest: note.isRest,
                                    isDotted: newDotted,
                                    hasAccent: note.hasAccent
                                )
                            )
                            
                            newCarry.notes.append(
                                Note(
                                    pitch: note.pitch,
                                    accidental: note.accidental,
                                    octave: note.octave,
                                    duration: carryDuration!,
                                    durationValue: note.durationValue * (Double(carryDuration!.rawValue) / Double(note.duration.rawValue)),
                                    timeModification: note.timeModification,
                                    dynamic: note.dynamic,
                                    graceNotes: note.graceNotes,
                                    tie: Note.Tie.Stop,
                                    isRest: note.isRest,
                                    isDotted: carryDotted,
                                    hasAccent: note.hasAccent
                                )
                            )
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
        
        if !chordGroup.isEmpty {
            beatSplitChords.append(chordGroup)
        }
        
        return true
    }
    
    func splitChordsIntoBeams() -> Bool {
        var beamGroup: [Chord] = []
        var timeModificationGroup: [Chord] = []
        var remainingNotesToAdd = 0

        for chordGroup in beatSplitChords {
            for chord in chordGroup {
                if remainingNotesToAdd == 0 {
                    if !beamGroup.isEmpty {
                        beamSplitChords.append(beamGroup)
                        beamGroup = []
                    }
                    
                    if !timeModificationGroup.isEmpty {
                        beamSplitChords.append(timeModificationGroup)
                        timeModificationGroup = []
                    }

                    if let timeModification = chord.notes.first?.timeModification,
                       case .custom(let actual, _) = timeModification {
                        remainingNotesToAdd = actual
                    }
                }

                if chord.notes.first?.timeModification != nil {
                    timeModificationGroup.append(chord)
                } else {
                    beamGroup.append(chord)
                    remainingNotesToAdd -= 1
                }
            }

            if !beamGroup.isEmpty {
                beamSplitChords.append(beamGroup)
                beamGroup = []
            }
        }

        if !timeModificationGroup.isEmpty {
            beamSplitChords.append(timeModificationGroup)
        }

        return true
    }
    
    func populateNoteGrid(splitChords: inout [[Chord]], noteGrid: inout [[[Note?]]]) -> Bool {
        if let gridRows = rows {
            let lowestGapIndex = (ledgerLines * 2) + 2
            
            for (groupIndex, chordGroup) in splitChords.enumerated() {
                var groupGrid: [[Note?]] = Array(repeating: Array(repeating: nil, count: chordGroup.count), count: gridRows)
                
                for (chordIndex, chord) in chordGroup.enumerated() {
                    for (noteIndex, note) in chord.notes.enumerated() {
                        if note.isRest {
                            groupGrid[0][chordIndex] = note
                        } else {
                            guard let distance = calculateGapBetweenLowestGapNote(note: note) else { continue }
                            var index = lowestGapIndex + (distance * (step == .Semitone ? 2 : 1))
                            
                            if index < 0 {
                                var modifiedNote = note
                                modifiedNote.increaseOctave()
                                splitChords[groupIndex][chordIndex].notes[noteIndex] = modifiedNote
                                index += 7
                            } else if index > gridRows - 1 {
                                var modifiedNote = note
                                modifiedNote.decreaseOctave()
                                splitChords[groupIndex][chordIndex].notes[noteIndex] = modifiedNote
                                index -= 7
                            }
                            
                            if index < 0 || index > gridRows - 1 { continue }
                            
                            groupGrid[gridRows - 1 - index][chordIndex] = splitChords[groupIndex][chordIndex].notes[noteIndex]
                        }
                    }
                }
                
                noteGrid.append(groupGrid)
            }
        } else { return false }
        
        return true
    }
    
    // consider semitone case
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

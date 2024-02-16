//
//  BarView.swift
//  Intervision
//
//  Created by Reuben on 11/02/2024.
//

import SwiftUI

struct BarView: View {
    
    @StateObject var barViewModel: BarViewModel
    let lineWidth: CGFloat = 3
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let rows = barViewModel.rows {
                    StaveView(rows: rows, ledgerLines: barViewModel.ledgerLines, geometry: geometry, lineWidth: lineWidth)
                    
                    if barViewModel.isBarRest {
                        let noteSize = 2 * (geometry.size.height / CGFloat(rows - 1))
                        
                        Circle()
                            .fill(.yellow)
                            .frame(width: noteSize, height: noteSize)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    } else {
                        NotesView(noteGrid: barViewModel.beatSplitNoteGrid, rows: rows, geometry: geometry)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    let testBVM1 = BarViewModel(
        bar: Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: Note.Pitch.C,
                        accidental: Note.Accidental.Sharp,
                        octave: Note.Octave.twoLine,
                        duration: Note.Duration.quarter,
                        durationValue: 0,
                        timeModification: nil,
                        dynamic: nil,
                        graceNotes: nil,
                        tie: nil,
                        isRest: false,
                        isDotted: true,
                        hasAccent: false
                    ),
                    Note(
                        pitch: Note.Pitch.F,
                        accidental: Note.Accidental.Sharp,
                        octave: Note.Octave.oneLine,
                        duration: Note.Duration.quarter,
                        durationValue: 0,
                        timeModification: nil,
                        dynamic: nil,
                        graceNotes: nil,
                        tie: nil,
                        isRest: false,
                        isDotted: true,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    Note(
                        pitch: Note.Pitch.F,
                        accidental: Note.Accidental.Sharp,
                        octave: Note.Octave.twoLine,
                        duration: Note.Duration.eighth,
                        durationValue: 0,
                        timeModification: nil,
                        dynamic: nil,
                        graceNotes: nil,
                        tie: nil,
                        isRest: false,
                        isDotted: true,
                        hasAccent: false
                    ),
                    Note(
                        pitch: Note.Pitch.B,
                        accidental: nil,
                        octave: Note.Octave.twoLine,
                        duration: Note.Duration.eighth,
                        durationValue: 0,
                        timeModification: nil,
                        dynamic: nil,
                        graceNotes: nil,
                        tie: nil,
                        isRest: false,
                        isDotted: true,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    Note(
                        pitch: nil,
                        accidental: nil,
                        octave: nil,
                        duration: Note.Duration.sixteenth,
                        durationValue: 0,
                        timeModification: nil,
                        dynamic: nil,
                        graceNotes: nil,
                        tie: nil,
                        isRest: true,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    Note(
                        pitch: Note.Pitch.C,
                        accidental: Note.Accidental.Sharp,
                        octave: Note.Octave.small,
                        duration: Note.Duration.eighth,
                        durationValue: 0,
                        timeModification: nil,
                        dynamic: nil,
                        graceNotes: nil,
                        tie: nil,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    Note(
                        pitch: nil,
                        accidental: nil,
                        octave: nil,
                        duration: Note.Duration.eighth,
                        durationValue: 0,
                        timeModification: nil,
                        dynamic: nil,
                        graceNotes: nil,
                        tie: nil,
                        isRest: true,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    Note(
                        pitch: Note.Pitch.B,
                        accidental: Note.Accidental.Sharp,
                        octave: Note.Octave.oneLine,
                        duration: Note.Duration.sixteenth,
                        durationValue: 0,
                        timeModification: .custom(actual: 3, normal: 2),
                        dynamic: nil,
                        graceNotes: nil,
                        tie: nil,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    Note(
                        pitch: Note.Pitch.C,
                        accidental: Note.Accidental.Sharp,
                        octave: Note.Octave.twoLine,
                        duration: Note.Duration.sixteenth,
                        durationValue: 0,
                        timeModification: .custom(actual: 3, normal: 2),
                        dynamic: nil,
                        graceNotes: nil,
                        tie: nil,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ]),
                Chord(notes: [
                    Note(
                        pitch: Note.Pitch.D,
                        accidental: Note.Accidental.Sharp,
                        octave: Note.Octave.twoLine,
                        duration: Note.Duration.sixteenth,
                        durationValue: 0,
                        timeModification: .custom(actual: 3, normal: 2),
                        dynamic: nil,
                        graceNotes: nil,
                        tie: nil,
                        isRest: false,
                        isDotted: false,
                        hasAccent: false
                    )
                ])
            ],
            tempo: Bar.Tempo.quarter(bpm: 120),
            clef: Bar.Clef.Treble,
            timeSignature: Bar.TimeSignature.custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            volta: nil,
            keySignature: Bar.KeySignature.CMajor
        ),
        gaps: 4,
        step: BarViewModel.Step.Note
    )
    
    let testBarRest = BarViewModel(
        bar: Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: nil,
                        accidental: nil,
                        octave: nil,
                        duration: Note.Duration.bar,
                        durationValue: 0,
                        timeModification: nil,
                        dynamic: nil,
                        graceNotes: nil,
                        tie: nil,
                        isRest: true,
                        isDotted: false,
                        hasAccent: false
                    )
                ])
            ],
            tempo: Bar.Tempo.quarter(bpm: 120),
            clef: Bar.Clef.Treble,
            timeSignature: Bar.TimeSignature.custom(beats: 4, noteValue: 4),
            repeat: nil,
            doubleLine: false,
            volta: nil,
            keySignature: Bar.KeySignature.CMajor
        ),
        gaps: 4,
        step: BarViewModel.Step.Note
    )
    
    return BarView(barViewModel: testBVM1)
}

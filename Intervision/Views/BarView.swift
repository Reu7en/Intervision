//
//  BarView.swift
//  Intervision
//
//  Created by Reuben on 11/02/2024.
//

import SwiftUI

struct BarView: View {
    
    @StateObject var barViewModel: BarViewModel
    
    var body: some View {
        ZStack {
            
        }
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
                        octave: Note.Octave.small,
                        duration: Note.Duration.quarter,
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
                        pitch: Note.Pitch.G,
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
                    ),
                    Note(
                        pitch: Note.Pitch.B,
                        accidental: nil,
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
                        pitch: Note.Pitch.E,
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
                        pitch: Note.Pitch.C,
                        accidental: Note.Accidental.Sharp,
                        octave: Note.Octave.small,
                        duration: Note.Duration.quarter,
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
                        pitch: Note.Pitch.G,
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
                    ),
                    Note(
                        pitch: Note.Pitch.B,
                        accidental: nil,
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
                        pitch: Note.Pitch.E,
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
        step: BarViewModel.Step.Tone
    )
    
    let testBVM2 = BarViewModel(
        bar: Bar(
            chords: [
                Chord(notes: [
                    Note(
                        pitch: Note.Pitch.C,
                        accidental: Note.Accidental.Sharp,
                        octave: Note.Octave.small,
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
                        pitch: Note.Pitch.G,
                        accidental: Note.Accidental.Sharp,
                        octave: Note.Octave.small,
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
                        octave: Note.Octave.small,
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
                        pitch: Note.Pitch.E,
                        accidental: Note.Accidental.Sharp,
                        octave: Note.Octave.small,
                        duration: Note.Duration.quarter,
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
                        isDotted: true,
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
        step: BarViewModel.Step.Tone
    )
    
    return BarView(barViewModel: testBVM1)
}

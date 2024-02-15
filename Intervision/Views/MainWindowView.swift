//
//  MainWindowView.swift
//  Intervision
//
//  Created by Reuben on 06/02/2024.
//

import SwiftUI

struct MainWindowView: View {
    
    @StateObject private var scoreViewModel = ScoreViewModel()
    
    var body: some View {
        ScoreView()
            .environmentObject(scoreViewModel)
            .onAppear {
                TestLoad.testLoad()
            }
//        HomeView()

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
        
        let testBVM3 = BarViewModel(
            bar: Bar(
                chords: [
                    Chord(notes: [
                        Note(
                            pitch: Note.Pitch.C,
                            accidental: nil,
                            octave: Note.Octave.twoLine,
                            duration: Note.Duration.sixteenth,
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
                            octave: Note.Octave.twoLine,
                            duration: Note.Duration.sixteenth,
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
                            pitch: Note.Pitch.D,
                            accidental: nil,
                            octave: Note.Octave.twoLine,
                            duration: Note.Duration.sixteenth,
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
                            pitch: Note.Pitch.D,
                            accidental: Note.Accidental.Sharp,
                            octave: Note.Octave.twoLine,
                            duration: Note.Duration.sixteenth,
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
                            pitch: Note.Pitch.B,
                            accidental: Note.Accidental.Sharp,
                            octave: Note.Octave.twoLine,
                            duration: Note.Duration.sixteenth,
                            durationValue: 0,
                            timeModification: Note.TimeModification.custom(actual: 5, normal: 4),
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
                            pitch: Note.Pitch.F,
                            accidental: Note.Accidental.Sharp,
                            octave: Note.Octave.twoLine,
                            duration: Note.Duration.sixteenth,
                            durationValue: 0,
                            timeModification: Note.TimeModification.custom(actual: 5, normal: 4),
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
                            pitch: Note.Pitch.A,
                            accidental: Note.Accidental.Sharp,
                            octave: Note.Octave.twoLine,
                            duration: Note.Duration.sixteenth,
                            durationValue: 0,
                            timeModification: Note.TimeModification.custom(actual: 5, normal: 4),
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
                            timeModification: Note.TimeModification.custom(actual: 5, normal: 4),
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
                            timeModification: Note.TimeModification.custom(actual: 5, normal: 4),
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
                            duration: Note.Duration.eighth,
                            durationValue: 0,
                            timeModification: Note.TimeModification.custom(actual: 3, normal: 2),
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
                            duration: Note.Duration.eighth,
                            durationValue: 0,
                            timeModification: Note.TimeModification.custom(actual: 3, normal: 2),
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
                            duration: Note.Duration.eighth,
                            durationValue: 0,
                            timeModification: Note.TimeModification.custom(actual: 3, normal: 2),
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
        BarView(barViewModel: testBVM1)
    }
}

#Preview {
    MainWindowView()
}

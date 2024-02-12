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
//        ScoreView()
//            .environmentObject(scoreViewModel)
//            .onAppear {
//                TestLoad.testLoad()
//            }
//        HomeView()
        /*
         case subContra = 0
         case contra = 1
         case great = 2
         case small = 3
         case oneLine = 4
         case twoLine = 5
         case threeLine = 6
         case fourLine = 7
         case fiveLine = 8
         */
        let testBVM3 = BarViewModel(
            bar: Bar(
                chords: [
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
        BarView(barViewModel: testBVM3)
    }
}

#Preview {
    MainWindowView()
}

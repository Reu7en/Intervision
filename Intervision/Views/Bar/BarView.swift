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
                        HStack(spacing: 0) {
                            ForEach(0..<barViewModel.beatSplitNoteGrid.count, id: \.self) { beatIndex in
                                HStack(spacing: 0) {
                                    GeometryReader { beatGeometry in
                                        ForEach(0..<barViewModel.beatSplitNoteGrid[beatIndex].count, id: \.self) { rowIndex in
                                            ForEach(0..<barViewModel.beatSplitNoteGrid[beatIndex][rowIndex].count, id: \.self) { columnIndex in
                                                if let note = barViewModel.beatSplitNoteGrid[beatIndex][rowIndex][columnIndex] {
                                                    let noteSize = 2 * (geometry.size.height / CGFloat(rows - 1))
                                                    let notePosition =
                                                    calculateNotePosition(
                                                        isRest: note.isRest,
                                                        rowIndex: rowIndex,
                                                        columnIndex: columnIndex,
                                                        totalRows: rows,
                                                        totalColumns: barViewModel.beatSplitNoteGrid[beatIndex][rowIndex].count,
                                                        geometry: beatGeometry
                                                    )
                                                    
                                                    NoteView(size: noteSize, isHollow: note.duration.isHollow)
                                                        .position(notePosition)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .padding(.horizontal)
                                .border(.blue)
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
}

extension BarView {
    func calculateNotePosition(isRest: Bool, rowIndex: Int, columnIndex: Int, totalRows: Int, totalColumns: Int, geometry: GeometryProxy) -> CGPoint {
        let xPosition = (totalColumns == 1) ? 0 : (geometry.size.width / CGFloat(totalColumns - 1)) * CGFloat(columnIndex)
        let yPosition = isRest ? geometry.size.height / 2 : (geometry.size.height / CGFloat(totalRows - 1)) * CGFloat(rowIndex)
        
        return CGPoint(x: xPosition, y: yPosition)
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
        step: BarViewModel.Step.Tone
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
        step: BarViewModel.Step.Tone
    )
    
    return BarView(barViewModel: testBVM1)
}

//
//  BarView.swift
//  Intervision
//
//  Created by Reuben on 11/02/2024.
//

import SwiftUI

struct BarView: View {
    
    @StateObject var barViewModel: BarViewModel
    let lineWidth: CGFloat = 2
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let rows = barViewModel.rows {
                    StaveView(rows: rows, ledgerLines: barViewModel.ledgerLines, geometry: geometry, lineWidth: lineWidth)
                }
            }
//            .border(Color.blue.opacity(0.5))
        }
        .padding()
//        GeometryReader { geometry in
//            ZStack {
//                // Stave Lines
//                if let rows = barViewModel.rows {
//                    VStack(spacing: 0) {
//                        ForEach(0..<rows, id: \.self) { index in
////                            let shouldDrawLine = (index % 2 != 0) && (index >= barViewModel.ledgerLines * 2 - 1) && (index <= rows - barViewModel.ledgerLines * 2 - 1)
//                            let shouldDrawLine = true
//                            Path { path in
//                                let yPosition = CGFloat(CGFloat(index) * CGFloat(CGFloat(geometry.size.height) / CGFloat(rows)))
//                                
//                                path.move(to: CGPoint(x: 0, y: yPosition))
//                                path.addLine(to: CGPoint(x: geometry.size.width, y: yPosition))
//                            }
//                            .stroke(Color.black, lineWidth: shouldDrawLine ? lineWidth : 1)
////                            .stroke(Color.green, lineWidth: !shouldDrawLine ? lineWidth : 0)
//                        }
//                    }
//                    .frame(maxHeight: .infinity)
//                    .border(.blue)
//                }
//                
//                // Note Heads
////                if let grid = barViewModel.noteGrid,
////                   let rows = barViewModel.rows {
////                    HStack(spacing: 0) {
////                        ForEach(0..<grid.count, id: \.self) { beatIndex in
////                            HStack(spacing: 0) {
////                                GeometryReader { beatGeometry in
////                                    ForEach(0..<grid[beatIndex].count, id: \.self) { rowIndex in
////                                        ForEach(0..<grid[beatIndex][rowIndex].count, id: \.self) { columnIndex in
////                                            if let note = grid[beatIndex][rowIndex][columnIndex] {
////                                                let notePosition = calculateNotePosition(rowIndex: rowIndex, columnIndex: columnIndex, totalRows: rows, totalColumns: grid[beatIndex][rowIndex].count, geometry: beatGeometry)
////                                                
////                                                Circle()
////                                                    .frame(width: 20, height: 20)
////                                                    .position(notePosition)
////                                            }
////                                        }
////                                    }
////                                }
////                                .border(.red)
////                            }
////                            .padding(.horizontal)
////                        }
////                    }
////                }
//            }
//            .frame(maxHeight: .infinity)
////            .padding()
//        }
    }
}

extension BarView {
    func calculateNotePosition(rowIndex: Int, columnIndex: Int, totalRows: Int, totalColumns: Int, geometry: GeometryProxy) -> CGPoint {
        let xPosition = (totalColumns == 1) ? 0 : (geometry.size.width / CGFloat(totalColumns - 1)) * CGFloat(columnIndex)
        let yPosition = (geometry.size.height / CGFloat(totalRows)) * CGFloat(rowIndex)
        
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

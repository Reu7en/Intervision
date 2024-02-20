//
//  NotesView.swift
//  Intervision
//
//  Created by Reuben on 16/02/2024.
//

import SwiftUI

struct NotesView: View {
    
    @StateObject var barViewModel: BarViewModel
    
    let noteGrid: [[[Note?]]]
    let rows: Int
    let geometry: GeometryProxy
    let scale: CGFloat
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<noteGrid.count, id: \.self) { beatIndex in
                HStack(spacing: 0) {
                    GeometryReader { beatGeometry in
                        ForEach(0..<noteGrid[beatIndex].count, id: \.self) { rowIndex in
                            ForEach(0..<noteGrid[beatIndex][rowIndex].count, id: \.self) { columnIndex in
                                if let note = noteGrid[beatIndex][rowIndex][columnIndex] {
                                    let noteSize = 2 * (geometry.size.height / CGFloat(rows - 1))
                                    let notePosition =
                                    BarViewModel.calculateNotePosition(
                                        isRest: note.isRest,
                                        rowIndex: rowIndex,
                                        columnIndex: columnIndex,
                                        totalRows: rows,
                                        totalColumns: noteGrid[beatIndex][rowIndex].count,
                                        geometry: beatGeometry
                                    )
                                    
                                    if note.isRest {
                                        RestView(size: noteSize, duration: note.duration, isDotted: note.isDotted, scale: scale)
                                            .position(notePosition)
                                    } else {
                                        NoteHeadView(size: noteSize, isHollow: note.duration.isHollow)
                                            .position(notePosition)
                                        BeamsView(beamViewModel: BeamViewModel(beamGroups: barViewModel.beamSplitChords, noteGrid: noteGrid[beatIndex], geometry: geometry, beatGeometry: beatGeometry, middleStaveNote: barViewModel.middleStaveNote, rows: rows, noteSize: noteSize), scale: scale)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, geometry.size.width / 50)
                }
                .padding(.horizontal, geometry.size.width / 50)
            }
        }
    }
}

#Preview {
    GeometryReader { geometry in
        NotesView(barViewModel: BarViewModel(bar: Bar(chords: [], clef: Bar.Clef.Neutral, timeSignature: Bar.TimeSignature.common, doubleLine: false, keySignature: Bar.KeySignature.CMajor), gaps: 4, step: .Note, ledgerLines: 3), noteGrid: [[[Note?]]](), rows: 23, geometry: geometry, scale: 1.0)
    }
}

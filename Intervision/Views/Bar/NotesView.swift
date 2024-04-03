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
    let showClef: Bool
    let showKey: Bool
    let showTime: Bool
    let staveThickness: CGFloat
    
    var body: some View {
        HStack(spacing: 0) {
            if showClef {
                let clefHeight: CGFloat = (geometry.size.height / CGFloat(rows)) * CGFloat(barViewModel.gaps * 2) + (2 * staveThickness)
                
                ClefView(width: geometry.size.width / 15, height: clefHeight, clef: barViewModel.bar.clef)
            }
            
            if showKey {
                let keyHeight: CGFloat = (geometry.size.height / CGFloat(rows)) * CGFloat(barViewModel.gaps * 2) + (2 * staveThickness)
            
                KeyView(width: geometry.size.width / 10, height: keyHeight, key: barViewModel.bar.keySignature, gaps: barViewModel.gaps, lowestGapNote: barViewModel.lowestGapNote)
            }
            
            if showTime {
                let timeHeight: CGFloat = (geometry.size.height / CGFloat(rows)) * CGFloat(barViewModel.gaps * 2) + (2 * staveThickness)
                
                TimeSignatureView(height: timeHeight, timeSignature: barViewModel.bar.timeSignature)
            }
            
            ForEach(0..<noteGrid.count, id: \.self) { beatIndex in
                HStack(spacing: 0) {
                    GeometryReader { beatGeometry in
                        let noteSize = 2 * (geometry.size.height / CGFloat(rows - 1))
                        
                        ForEach(0..<noteGrid[beatIndex].count, id: \.self) { rowIndex in
                            ForEach(0..<noteGrid[beatIndex][rowIndex].count, id: \.self) { columnIndex in
                                if let note = noteGrid[beatIndex][rowIndex][columnIndex] {
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
                                        NoteHeadView(size: noteSize, isHollow: note.duration.isHollow, isDotted: note.isDotted)
                                            .position(notePosition)
                                        
                                        if let accidental =  barViewModel.shouldRenderAccidental(note) {
                                            AccidentalView(accidental: accidental)
                                                .frame(width: noteSize * 1.25, height: noteSize * 1.25)
                                                .position(notePosition)
                                                .offset(x: -noteSize * 1.1)
                                        }
                                    }
                                }
                            }
                        }
                        
                        BeamsView(beamViewModel: BeamViewModel(beamGroups: barViewModel.beamSplitChords[beatIndex], noteGrid: noteGrid, geometry: geometry, beatGeometry: beatGeometry, middleStaveNote: barViewModel.middleStaveNote, rows: rows, noteSize: noteSize, beatIndex: beatIndex), scale: scale)
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
        NotesView(barViewModel: BarViewModel(bar: Bar(chords: [], clef: Bar.Clef.Neutral, timeSignature: Bar.TimeSignature.common, doubleLine: false, keySignature: Bar.KeySignature.CMajor), gaps: 4, step: .Note, ledgerLines: 3), noteGrid: [[[Note?]]](), rows: 23, geometry: geometry, scale: 1.0, showClef: true, showKey: true, showTime: true, staveThickness: 3)
    }
}

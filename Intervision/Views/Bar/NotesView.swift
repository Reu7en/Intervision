//
//  NotesView.swift
//  Intervision
//
//  Created by Reuben on 16/02/2024.
//

import SwiftUI

struct NotesView: View {
    
    let noteGrid: [[[Note?]]]
    let rows: Int
    let geometry: GeometryProxy
    
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
                                        RestView(size: noteSize, duration: note.duration, isDotted: note.isDotted)
                                            .position(notePosition)
                                    } else {
                                        NoteHeadView(size: noteSize, isHollow: note.duration.isHollow)
                                            .position(notePosition)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    GeometryReader { geometry in
        NotesView(noteGrid: [[[Note?]]](), rows: 23, geometry: geometry)
    }
}

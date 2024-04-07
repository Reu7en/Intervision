//
//  BeatView.swift
//  Intervision
//
//  Created by Reuben on 06/04/2024.
//

import SwiftUI

struct BeatView: View {
    
    @ObservedObject var beatViewModel: BeatViewModel
    
    let scale: CGFloat
    
    var body: some View {
        ForEach(0..<beatViewModel.notePositions.count, id: \.self) { groupIndex in
            ForEach(0..<beatViewModel.notePositions[groupIndex].count, id: \.self) { chordIndex in
                ForEach(0..<beatViewModel.notePositions[groupIndex][chordIndex].count, id: \.self) { noteIndex in
                    let notePosition = beatViewModel.notePositions[groupIndex][chordIndex][noteIndex]
                    
                    NoteHeadView(
                        size: beatViewModel.noteSize,
                        isHollow: false,
                        isDotted: false
                    )
                    .position(notePosition)
                }
            }
        }
        
        ForEach(0..<beatViewModel.restPositions.count, id: \.self) { positionIndex in
            let restPosition = beatViewModel.restPositions[positionIndex]
            
            RestView(
                size: beatViewModel.noteSize,
                duration: beatViewModel.restDurations[positionIndex],
                isDotted: beatViewModel.restIsDotted[positionIndex],
                scale: scale
            )
            .position(restPosition)
        }
        
        if !beatViewModel.beamGroupChords.isEmpty && !beatViewModel.notePositions.isEmpty {
            LinesView(
                linesViewModel: LinesViewModel(
                    beamGroups: beatViewModel.beamGroupChords,
                    positions: beatViewModel.notePositions,
                    middleStaveNote: beatViewModel.middleStaveNote,
                    barGeometry: beatViewModel.barGeometry,
                    beatGeometry: beatViewModel.beatGeometry, 
                    noteSize: beatViewModel.noteSize
                )
            )
        }
    }
}

#Preview {
    GeometryReader { geometry in
        BeatView(beatViewModel: BeatViewModel(noteGrid: [], barGeometry: geometry, beatGeometry: geometry, beamGroupChords: [], middleStaveNote: nil), scale: 0)
    }
}

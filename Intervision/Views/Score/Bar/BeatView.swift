//
//  BeatView.swift
//  Intervision
//
//  Created by Reuben on 06/04/2024.
//

import SwiftUI

struct BeatView: View {
    
    @ObservedObject var beatViewModel: BeatViewModel
    
    var body: some View {
        ForEach(0..<beatViewModel.notePositions.count, id: \.self) { chordIndex in
            ForEach(0..<beatViewModel.notePositions[chordIndex].count, id: \.self) { noteIndex in
                let notePosition = beatViewModel.notePositions[chordIndex][noteIndex]
                
                NoteHeadView(
                    size: beatViewModel.noteSize,
                    isHollow: beatViewModel.isHollow[chordIndex],
                    isDotted: beatViewModel.noteIsDotted[chordIndex]
                )
                .position(notePosition.0)
                .offset(x: beatViewModel.noteSize * CGFloat(notePosition.1) - CGFloat(notePosition.1) * beatViewModel.barGeometry.size.height / 70)
            }
        }
        
        ForEach(0..<beatViewModel.restPositions.count, id: \.self) { positionIndex in
            let restPosition = beatViewModel.restPositions[positionIndex]
            
            RestView(
                gapHeight: beatViewModel.noteSize,
                duration: beatViewModel.restDurations[positionIndex],
                isDotted: beatViewModel.restIsDotted[positionIndex]
            )
            .position(restPosition)
        }
        
        ForEach(0..<beatViewModel.accidentalPositions.count, id: \.self) { positionIndex in
            let accidentalPosition = beatViewModel.accidentalPositions[positionIndex]
            
            AccidentalView(
                accidental: beatViewModel.accidentals[positionIndex],
                noteSize: beatViewModel.noteSize
            )
            .frame(height: beatViewModel.noteSize * 1.75)
            .position(accidentalPosition.0)
            .offset(x: beatViewModel.noteSize * CGFloat(accidentalPosition.1))
        }
        
        if !beatViewModel.beatBeamGroupChords.isEmpty && !beatViewModel.notePositions.isEmpty {
            LinesView(
                linesViewModel: LinesViewModel(
                    beamGroups: beatViewModel.beatBeamGroupChords,
                    positions: beatViewModel.groupPositions,
                    middleStaveNote: beatViewModel.middleStaveNote,
                    barGeometry: beatViewModel.barGeometry,
                    beatGeometry: beatViewModel.beatGeometry, 
                    noteSize: beatViewModel.noteSize,
                    beamDirections: beatViewModel.beamDirections
                )
            )
        }
    }
}

#Preview {
    GeometryReader { geometry in
        BeatView(beatViewModel: BeatViewModel(noteGrid: [], barGeometry: geometry, beatGeometry: geometry, beamGroupChords: [], middleStaveNote: nil))
    }
}

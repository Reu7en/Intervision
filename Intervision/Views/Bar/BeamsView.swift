//
//  BeamsView.swift
//  Intervision
//
//  Created by Reuben on 16/02/2024.
//

import SwiftUI

struct BeamsView: View {
    
    @StateObject var beamViewModel: BeamViewModel
    
    let scale: CGFloat
    
    var body: some View {
        ForEach(0..<beamViewModel.positions.count, id: \.self) { beamIndex in
            let direction = beamViewModel.beamDirections[beamIndex]
            let stemLength = beamViewModel.geometry.size.height / 4
            let xOffset = (direction == .Upward) ? beamViewModel.noteSize / 2.3 : -(beamViewModel.noteSize / 2.3)
            
            ForEach(0..<beamViewModel.positions[beamIndex].count, id: \.self) { chordIndex in
                ForEach(0..<beamViewModel.positions[beamIndex][chordIndex].count, id: \.self) { noteIndex in
                    let position = beamViewModel.positions[beamIndex][chordIndex][noteIndex]
                    
                    let duration = beamViewModel.beamGroups[beamIndex][chordIndex].notes[noteIndex].duration
                    
                    if !(duration == .bar || duration == .breve || duration == .whole) {
                        StemView(position: position, direction: direction, stemLength: stemLength, xOffset: xOffset, scale: scale)
                    }
                }
                
                if let furthestPosition = beamViewModel.findFurthestPosition(in: beamViewModel.positions[beamIndex][chordIndex], direction: direction) {
                    if beamViewModel.positions[beamIndex].count <= 1 {
                        NoteTailView(furthestPosition: furthestPosition, duration: beamViewModel.beamGroups[beamIndex][chordIndex].notes.first?.duration ?? Note.Duration.bar, stemLength: stemLength, direction: direction, xOffset: xOffset, scale: scale)
                    }
                }
            }
            
            if beamViewModel.positions[beamIndex].count > 1 {
                if let furthestStartPosition = beamViewModel.findFurthestPosition(in: beamViewModel.positions[beamIndex][0], direction: direction),
                   let furthestEndPosition = beamViewModel.findFurthestPosition(in: beamViewModel.positions[beamIndex][beamViewModel.positions[beamIndex].count - 1], direction: direction) {
                    
//                    Circle()
//                        .fill(.green)
//                        .frame(width: 5, height: 5)
//                        .position(furthestStartPosition)
//                    
//                    Circle()
//                        .fill(.red)
//                        .frame(width: 5, height: 5)
//                        .position(furthestEndPosition)
                    
                    let durations = beamViewModel.beamGroups[beamIndex].map { $0.notes.first?.duration ?? Note.Duration.bar }
                    
                    BeamLineView(furthestStartPosition: furthestStartPosition, furthestEndPosition: furthestEndPosition, durations: durations, timeModification: beamViewModel.beamGroups[beamIndex][0].notes.first?.timeModification, stemLength: stemLength, direction: direction, xOffset: xOffset, scale: scale)
                }
            }
        }
    }
}

#Preview {
    GeometryReader { geometry in
        BeamsView(beamViewModel: BeamViewModel(beamGroups: [], noteGrid: [], geometry: geometry, beatGeometry: geometry, middleStaveNote: Note(duration: Note.Duration.bar, durationValue: -1, isRest: true, isDotted: false, hasAccent: false), rows: 23, noteSize: 10, beatIndex: 0), scale: 1.0)
    }
}

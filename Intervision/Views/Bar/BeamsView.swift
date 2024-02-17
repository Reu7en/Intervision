//
//  BeamsView.swift
//  Intervision
//
//  Created by Reuben on 16/02/2024.
//

import SwiftUI

struct BeamsView: View {
    
    @StateObject var beamViewModel: BeamViewModel
    
    let beamThickness: CGFloat = 5
    
    var body: some View {
        ForEach(0..<beamViewModel.positions.count, id: \.self) { beamIndex in
            let direction = beamViewModel.beamDirections[beamIndex]
            let stemLength = beamViewModel.geometry.size.height / 4
            let xOffset = (direction == .Upward) ? beamViewModel.noteSize / 2.3 : -(beamViewModel.noteSize / 2.3)
            
            ForEach(0..<beamViewModel.positions[beamIndex].count, id: \.self) { chordIndex in
                ForEach(0..<beamViewModel.positions[beamIndex][chordIndex].count, id: \.self) { noteIndex in
                    let position = beamViewModel.positions[beamIndex][chordIndex][noteIndex]
                    
                    StemView(position: position, direction: direction, stemLength: stemLength, xOffset: xOffset)
                }
                
                if let furthestPosition = beamViewModel.findFurthestPosition(in: beamViewModel.positions[beamIndex][chordIndex], direction: direction) {
                    NoteTailView(furthestPosition: furthestPosition, duration: beamViewModel.beamGroups[beamIndex][chordIndex].notes.first?.duration ?? Note.Duration.bar, stemLength: stemLength, direction: direction, xOffset: xOffset)
                }
            }
        }
    }
}

#Preview {
    GeometryReader { geometry in
        BeamsView(beamViewModel: BeamViewModel(beamGroups: [], noteGrid: [], geometry: geometry, beatGeometry: geometry, middleStaveNote: Note(duration: Note.Duration.bar, durationValue: -1, isRest: true, isDotted: false, hasAccent: false), rows: 23, noteSize: 10))
    }
}

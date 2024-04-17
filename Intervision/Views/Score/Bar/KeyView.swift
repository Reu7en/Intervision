//
//  KeyView.swift
//  Intervision
//
//  Created by Reuben on 20/02/2024.
//

import SwiftUI

struct KeyView: View {
    
    let key: Bar.KeySignature
    let gapHeight: CGFloat
    let gaps: Int
    let middleStaveNote: Note?
    
    var body: some View {
        HStack(spacing: 0) {
            if let middleStaveNote = middleStaveNote,
               let middlePitch = middleStaveNote.pitch {
                ForEach(0..<key.alteredNotes.count, id: \.self) { noteIndex in
                    let pitch = key.alteredNotes[noteIndex].0
                    let distance = middlePitch.distanceFromC() - pitch.distanceFromC()
                    let yOffset = CGFloat(distance - 1) * (gapHeight / 2)
                    
                    Image(key.sharps ? "Sharp" : "Flat")
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                        .frame(height: gapHeight * 2)
                        .offset(y: yOffset)
                }
            }
        }
    }
}

#Preview {
    KeyView(key: .CSharpMajor, gapHeight: 50, gaps: 4, middleStaveNote: Note(pitch: .B, accidental: nil, octave: nil, octaveShift: nil, duration: .bar, durationValue: -1, timeModification: nil, changeDynamic: nil, graceNotes: nil, tie: nil, slur: nil, isRest: true, isDotted: false, hasAccent: false, id: UUID()))
        .frame(width: 1000, height: 500)
}

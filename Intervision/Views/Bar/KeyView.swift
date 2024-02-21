//
//  KeyView.swift
//  Intervision
//
//  Created by Reuben on 20/02/2024.
//

import SwiftUI

struct KeyView: View {
    
    let width: CGFloat
    let height: CGFloat
    let key: Bar.KeySignature
    let gaps: Int
    let lowestGapNote: Note?
    
    var body: some View {
        
        let maxSharpsOrFlats = key.alteredNotes.count
        let horizontalSpacing = width / CGFloat(maxSharpsOrFlats + 1)
        
        ZStack {
            if let lowestGapNote = lowestGapNote,
               let lowestPitch = lowestGapNote.pitch {
                ForEach(0..<key.alteredNotes.count, id: \.self) { noteIndex in
                    let pitch = key.alteredNotes[noteIndex].0
                    let distance = lowestPitch.distanceFromC() - pitch.distanceFromC()
                    let yPosition = key.sharps ? CGFloat(distance < -1 ? distance + 7 : distance) * height / (CGFloat(gaps * 2)) : CGFloat(distance < 1 ? distance + 7 : distance) * height / (CGFloat(gaps * 2))
                    let yOffset = key.sharps ? 0 : -height / 10
                    
                    Image(key.sharps ? "Sharp" : "Flat")
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                        .frame(height: height / CGFloat(CGFloat(gaps) / CGFloat(1.75)))
                        .position(x: CGFloat(noteIndex + 1) * horizontalSpacing, y: yPosition + yOffset)
                }
            }
        }
        .frame(width: width, height: height)
    }
}

#Preview {
    KeyView(width: 50, height: 100, key: .AFlatMajor, gaps: 4, lowestGapNote: nil)
}

//
//  PianoKeysView.swift
//  Intervision
//
//  Created by Reuben on 23/02/2024.
//

import SwiftUI

struct PianoKeysView: View {
    
    let geometry: GeometryProxy
    let octaves: Int
    let whiteKeysPerOctave = 7
    let blackKeysPerOctave = 5
    let totalKeysPerOctave = 12
    
    var body: some View {
        
        let rows = octaves * totalKeysPerOctave
        let octaveHeight = geometry.size.height / CGFloat(rows / totalKeysPerOctave) * 2
        let whiteKeyHeight = octaveHeight / CGFloat(whiteKeysPerOctave)
        let blackKeyHeight = octaveHeight / CGFloat(totalKeysPerOctave)
        
        VStack(spacing: 0) {
            ForEach(0..<octaves, id: \.self) { rowIndex in
                ZStack {
                    VStack(spacing: 0) {
                        ForEach(0..<whiteKeysPerOctave, id: \.self) { whiteKeyIndex in
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: geometry.size.width / 10, height: whiteKeyHeight)
                                .border(Color.black)
                        }
                    }
                    
                    VStack(spacing: 0) {
                        ForEach(0..<totalKeysPerOctave, id: \.self) { keyIndex in
                            HStack(spacing: 0) {
                                Rectangle()
                                    .fill([1, 3, 5, 8, 10].contains(keyIndex) ? Color.black : Color.clear)
                                    .frame(width: geometry.size.width / 25, height: blackKeyHeight)
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    GeometryReader { geometry in
        PianoKeysView(geometry: geometry, octaves: 9)
    }
}

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
    let width: CGFloat
    let rowHeight: CGFloat
    let whiteKeysPerOctave = 7
    let blackKeysPerOctave = 5
    let totalKeysPerOctave = 12
    
    var body: some View {
        
        let octaveHeight = rowHeight * CGFloat(totalKeysPerOctave)
        let whiteKeyHeight = octaveHeight / CGFloat(whiteKeysPerOctave)
        let blackKeyHeight = octaveHeight / CGFloat(totalKeysPerOctave)
        
        LazyVStack(spacing: 0) {
            ForEach(0..<octaves, id: \.self) { octaveIndex in
                ZStack {
                    VStack(spacing: 0) {
                        ForEach(0..<whiteKeysPerOctave, id: \.self) { whiteKeyIndex in
                            ZStack {
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: width, height: whiteKeyHeight)
                                    .border(Color.black)
                                
                                if whiteKeyIndex == whiteKeysPerOctave - 1 {
                                    HStack(spacing: 0) {
                                        Spacer()
                                        
                                        Text("C\(octaves - octaveIndex - 1)")
                                            .foregroundStyle(Color.gray)
                                            .padding(.horizontal, geometry.size.width / 200)
                                    }
                                }
                            }
                        }
                    }
                    
                    VStack(spacing: 0) {
                        ForEach(0..<totalKeysPerOctave, id: \.self) { keyIndex in
                            HStack(spacing: 0) {
                                Rectangle()
                                    .fill([1, 3, 5, 8, 10].contains(keyIndex) ? Color.black : Color.clear)
                                    .frame(width: width / 2.5, height: blackKeyHeight)
                                
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
        PianoKeysView(geometry: geometry, octaves: 9, width: 100, rowHeight: 10)
    }
}

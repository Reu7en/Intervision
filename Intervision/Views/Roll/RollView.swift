//
//  RollView.swift
//  Intervision
//
//  Created by Reuben on 23/02/2024.
//

import SwiftUI

struct RollView: View {
    
    @StateObject var rollViewModel: RollViewModel
    
    let scale: CGFloat = 1.0
    let octaves = 9
    
    var body: some View {
        GeometryReader { geometry in
            let pianoKeysWidth = geometry.size.width / 10
            let barWidth = geometry.size.width / 3
            
            ScrollView([.vertical, .horizontal]) {
                LazyHStack(spacing: 0, pinnedViews: .sectionHeaders) {
                    Section {
                        if let parts = rollViewModel.parts {
                            if parts.count > 0 {
                                LazyHStack(spacing: 0) {
                                    ForEach(0..<parts[0].bars.count, id: \.self) { barIndex in
                                        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                                            Section {
                                                ZStack {
                                                    let rows = octaves * 12
                                                    let rowHeight = geometry.size.height / CGFloat(rows / 2)
                                                    let beats = RollViewModel.getBeats(bar: parts[0].bars[0][0])
                                                    
                                                    LazyVStack(spacing: 0) {
                                                        ForEach(0..<rows, id: \.self) { rowIndex in
                                                            ZStack {
                                                                Rectangle()
                                                                    .fill([1, 3, 5, 8, 10].contains(rowIndex % 12) ? Color.black.opacity(0.5) : Color.black.opacity(0.125))
                                                                    .frame(height: rowHeight)
                                                                    .border(Color.black.opacity(0.25))
                                                                
                                                                ForEach(0..<beats, id: \.self) { beatIndex in
                                                                    Path { path in
                                                                        let xPosition = CGFloat(beatIndex) * (barWidth / CGFloat(beats))
                                                                        
                                                                        path.move(to: CGPoint(x: xPosition, y: 0))
                                                                        path.addLine(to: CGPoint(x: xPosition, y: rowHeight))
                                                                    }
                                                                    .stroke(Color.black.opacity(beatIndex == 0 ? 1.0 : 0.25))
                                                                }
                                                            }
                                                        }
                                                    }
                                                    
                                                    ForEach(0..<parts.count, id: \.self) { partIndex in
                                                        RollBarView(rollBarViewModel: RollBarViewModel(bars: parts[partIndex].bars[barIndex], octaves: octaves), geometry: geometry, barWidth: barWidth, pianoKeysWidth: pianoKeysWidth, rows: rows, rowHeight: rowHeight, partIndex: partIndex)
                                                    }
                                                }
                                            } header: {
                                                Rectangle()
                                                    .fill(Color.clear)
                                                    .frame(height: 25)
                                                    .overlay {
                                                        HStack(spacing: 0) {
                                                            Text("\(barIndex + 1)")
                                                                .foregroundStyle(Color.gray)
                                                                .padding(.horizontal, geometry.size.width / 200)
                                                                .overlay {
                                                                    Circle()
                                                                        .fill(Color.clear)
                                                                        .stroke(Color.gray)
                                                                }
                                                            
                                                            Spacer()
                                                        }
                                                    }
                                            }
                                        }
                                        .frame(width: barWidth)
                                    }
                                }
                            } else {
                                Color.clear
                                    .frame(width: geometry.size.width)
                            }
                        } else {
                            Color.clear
                                .frame(width: geometry.size.width)
                        }
                    } header: {
                        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                            Section {
                                PianoKeysView(geometry: geometry, octaves: octaves, width: pianoKeysWidth)
                            } header: {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 25)
                            }
                        }
                        .frame(width: pianoKeysWidth)
                    }
                }
            }
        }
    }
}

#Preview {
    RollView(rollViewModel: RollViewModel(score: Score()))
}

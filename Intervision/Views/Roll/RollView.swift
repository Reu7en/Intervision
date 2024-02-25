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
                        if let part = rollViewModel.part {
                            LazyHStack(spacing: 0) {
                                ForEach(0..<part.bars.count, id: \.self) { barIndex in
                                    LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                                        Section {
                                            ZStack {
                                                LazyVStack(spacing: 0) {
                                                    let rows = octaves * 12
                                                    
                                                    ForEach(0..<rows, id: \.self) { rowIndex in
                                                        Rectangle()
                                                            .fill([1, 3, 5, 8, 10].contains(rowIndex % 12) ? Color.black.opacity(0.5) : Color.black.opacity(0.125))
                                                            .frame(height: geometry.size.height / CGFloat(rows / 2))
                                                            .border(Color.black.opacity(0.25))
                                                    }
                                                }
                                                
                                                ForEach(0..<part.bars.count, id: \.self) { barIndex in
                                                    RollBarView(rollBarViewModel: RollBarViewModel(bars: part.bars[barIndex], octaves: octaves), geometry: geometry)
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
        .onAppear {
            rollViewModel.setPart(partIndex: 0)
        }
    }
}

#Preview {
    RollView(rollViewModel: RollViewModel(score: Score()))
}

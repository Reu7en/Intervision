//
//  BarView.swift
//  Intervision
//
//  Created by Reuben on 11/02/2024.
//

import SwiftUI

struct BarView: View {
    
    @StateObject var barViewModel: BarViewModel
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let staveThickness = 3 * scale
                
                StaveView(
                    rows: barViewModel.rows,
                    ledgerLines: barViewModel.ledgerLines,
                    geometry: geometry,
                    scale: scale,
                    thickness: staveThickness
                )
                
                if barViewModel.isBarRest {
                    RestView(
                        size: 2 * (geometry.size.height / CGFloat(barViewModel.rows - 1)),
                        duration: Note.Duration.bar,
                        isDotted: false,
                        scale: scale
                    )
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
                
                HStack(spacing: 0) {
                    if barViewModel.showClef {
                        let clefHeight: CGFloat = (geometry.size.height / CGFloat(barViewModel.rows)) * CGFloat(barViewModel.gaps * 2) + (2 * staveThickness)
                        
                        ClefView(width: geometry.size.width / 15, height: clefHeight, clef: barViewModel.bar.clef)
                    }
                    
                    if barViewModel.showKey {
                        let keyHeight: CGFloat = (geometry.size.height / CGFloat(barViewModel.rows)) * CGFloat(barViewModel.gaps * 2) + (2 * staveThickness)
                    
                        KeyView(width: geometry.size.width / 10, height: keyHeight, key: barViewModel.bar.keySignature, gaps: barViewModel.gaps, lowestGapNote: barViewModel.lowestGapNote)
                    }
                    
                    if barViewModel.showTime {
                        let timeHeight: CGFloat = (geometry.size.height / CGFloat(barViewModel.rows)) * CGFloat(barViewModel.gaps * 2) + (2 * staveThickness)
                        
                        TimeSignatureView(height: timeHeight, timeSignature: barViewModel.bar.timeSignature)
                    }
                    
                    if barViewModel.isBarRest {
                        Spacer()
                    } else {
                        HStack(spacing: 0) {
                            ForEach(0..<barViewModel.noteGrid.count, id: \.self) { beatIndex in
                                HStack(spacing: 0) {
                                    GeometryReader { beatGeometry in
                                        BeatView(
                                            beatViewModel: BeatViewModel(
                                                noteGrid: barViewModel.noteGrid[beatIndex],
                                                barGeometry: geometry,
                                                beatGeometry: beatGeometry,
                                                beamGroupChords: barViewModel.beamGroupChords[beatIndex],
                                                middleStaveNote: barViewModel.middleStaveNote
                                            ),
                                            scale: scale
                                        )
                                    }
                                }
                                .padding(.horizontal, geometry.size.width / 25)
                            }
                        }
                        .padding(.horizontal, geometry.size.width / 50)
                    }
                }
            }
            .onChange(of: geometry.size) {
                updateScale(with: geometry.size)
            }
            .onAppear {
                updateScale(with: geometry.size)
            }
        }
    }
    
    private func updateScale(with newSize: CGSize) {
        scale = newSize.height / 500
    }
}

#Preview {
    BarView(barViewModel: BarViewModel(bar: Bar(chords: [], clef: .Treble, timeSignature: .common, repeat: nil, doubleLine: false, keySignature: .CMajor)))
}

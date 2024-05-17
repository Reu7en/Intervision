//
//  BarView.swift
//  Intervision
//
//  Created by Reuben on 11/02/2024.
//

import SwiftUI

struct BarView: View {
    
    @EnvironmentObject var screenSizeViewModel: DynamicSizingViewModel
    
    @StateObject var barViewModel: BarViewModel
    
    var body: some View {
        GeometryReader { wholeGeometry in
            HStack(spacing: 0) {
                GeometryReader { geometry in
                    ZStack {
                        let staveThickness = geometry.size.height / 100
                        let gapHeight = 2 * (geometry.size.height / CGFloat(barViewModel.rows))
                        
                        StaveView(
                            rows: barViewModel.rows,
                            ledgerLines: barViewModel.ledgerLines,
                            geometry: geometry,
                            thickness: staveThickness
                        )
                        
                        HStack(spacing: 0) {
                            if barViewModel.showClef {
                                ClefView(
                                    clef: barViewModel.bar.clef,
                                    gapHeight: gapHeight
                                )
                                .padding(.horizontal, geometry.size.width / 100)
                            }
                            
                            if barViewModel.showKey {
                                KeyView(
                                    key: barViewModel.bar.keySignature,
                                    gapHeight: gapHeight,
                                    gaps: barViewModel.gaps,
                                    middleStaveNote: barViewModel.middleStaveNote
                                )
                                .padding(.horizontal, geometry.size.width / 100)
                            }
                            
                            if barViewModel.showTime {
                                TimeSignatureView(
                                    timeSignature: barViewModel.bar.timeSignature,
                                    gapHeight: gapHeight,
                                    gaps: barViewModel.gaps
                                )
                                .padding(.horizontal, geometry.size.width / 100)
                            }
                            
                            Spacer()
                            
                            if barViewModel.isBarRest {
                                RestView(
                                    gapHeight: gapHeight,
                                    duration: Note.Duration.bar,
                                    isDotted: false
                                )
                                
                                Spacer()
                            } else {
                                HStack(spacing: 0) {
                                    ForEach(0..<barViewModel.noteGrid.count, id: \.self) { beatIndex in
                                        HStack(spacing: 0) {
                                            GeometryReader { beatGeometry in
                                                BeatView(
                                                    beatViewModel: BeatViewModel(
                                                        noteGrid: &barViewModel.noteGrid[beatIndex],
                                                        barGeometry: geometry,
                                                        beatGeometry: beatGeometry,
                                                        beamGroupChords: barViewModel.beamGroupChords[beatIndex],
                                                        middleStaveNote: barViewModel.middleStaveNote
                                                    )
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
                }
            }
        }
    }
}

#Preview {
    BarView(barViewModel: BarViewModel(bar: Bar(chords: [], clef: .Treble, timeSignature: .common, repeat: nil, doubleLine: false, keySignature: .CMajor)))
        .environmentObject(DynamicSizingViewModel())
}

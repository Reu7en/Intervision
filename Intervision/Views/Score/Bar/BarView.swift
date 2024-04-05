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
                let rows = barViewModel.rows
                let staveThickness = 3 * scale
                
                StaveView(rows: rows, ledgerLines: barViewModel.ledgerLines, geometry: geometry, scale: scale, thickness: staveThickness)
                
                if barViewModel.isBarRest {
                    let restSize = 2 * (geometry.size.height / CGFloat(rows - 1))
                    
                    RestView(size: restSize, duration: Note.Duration.bar, isDotted: false, scale: scale)
                } else {
                    NotesView(barViewModel: barViewModel, noteGrid: barViewModel.noteGrid, rows: rows, geometry: geometry, scale: scale, showClef: barViewModel.showClef, showKey: barViewModel.showKey, showTime: barViewModel.showTime, staveThickness: staveThickness)
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
    BarView(barViewModel: BarViewModel(bar: Bar(chords: [], clef: .Treble, timeSignature: .common, doubleLine: false, keySignature: .CMajor)))
}

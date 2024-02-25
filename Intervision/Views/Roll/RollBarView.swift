//
//  RollBarView.swift
//  Intervision
//
//  Created by Reuben on 24/02/2024.
//

import SwiftUI

struct RollBarView: View {
    
    @StateObject var rollBarViewModel: RollBarViewModel
    
    let geometry: GeometryProxy
    let barWidth: CGFloat
    let rows: Int
    let segmentColors: [Color] = [
        .red,
        .blue,
        .green,
        .yellow
    ]
    
    var body: some View {
        LazyVStack {
            ForEach(0..<rollBarViewModel.segments.count, id: \.self) { staveIndex in
                let segmentColor = segmentColors[staveIndex]
                
                ForEach(0..<rollBarViewModel.segments[staveIndex].count, id: \.self) { segmentIndex in
                    let segment = rollBarViewModel.segments[staveIndex][segmentIndex]
                    let width = barWidth * segment.duration
                    let xOffset = barWidth * segment.durationPreceeding
                    let yOffset = (geometry.size.height / CGFloat(rows)) * CGFloat(segment.rowIndex)
                    
                    Rectangle()
                        .fill(segmentColor)
                        .frame(width: width, height: geometry.size.height / CGFloat(rows))
                        .position(x: xOffset, y: yOffset)
                        .id(UUID())
                }
            }
        }
    }
}

#Preview {
    GeometryReader { geometry in
        RollBarView(rollBarViewModel: RollBarViewModel(bars: [], octaves: 9), geometry: geometry, barWidth: 100, rows: 12)
    }
}

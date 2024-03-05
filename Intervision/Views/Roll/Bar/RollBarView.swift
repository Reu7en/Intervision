//
//  RollBarView.swift
//  Intervision
//
//  Created by Reuben on 24/02/2024.
//

import SwiftUI

struct RollBarView: View {
    
    let segments: [[Segment]]
    let barWidth: CGFloat
    let pianoKeysWidth: CGFloat
    let rowHeight: CGFloat
    let partIndex: Int
    
    var body: some View {
        ForEach(0..<segments.count, id: \.self) { staveIndex in
            let segmentColor = partIndex > RollViewModel.partSegmentColors.count - 1 ? Color.black : RollViewModel.partSegmentColors[partIndex]
            
            ForEach(0..<segments[staveIndex].count, id: \.self) { segmentIndex in
                let segment = segments[staveIndex][segmentIndex]
                let width = barWidth * CGFloat(segment.duration)
                let xPosition = barWidth * CGFloat(segment.durationPreceeding)
                let yPosition = rowHeight * CGFloat(segment.rowIndex)
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black)
                    .background (
                        RoundedRectangle(cornerRadius: 20)
                            .fill(segmentColor)
                    )
                    .frame(width: width, height: rowHeight)
                    .position(x: xPosition + (width / 2), y: yPosition + (rowHeight / 2))
            }
        }
    }
}

#Preview {
    RollBarView(segments: [], barWidth: 100, pianoKeysWidth: 100, rowHeight: 10, partIndex: 0)
}

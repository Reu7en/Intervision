//
//  RollBarView.swift
//  Intervision
//
//  Created by Reuben on 24/02/2024.
//

import SwiftUI

struct RollBarView: View {
    
    let segments: [[[[Segment]]]]
    let barIndex: Int
    let barWidth: CGFloat
    let rowHeight: CGFloat
    let colors: [Color]
    
    var body: some View {
        ForEach(0..<segments.count, id: \.self) { partIndex in
            let barSegments = segments[partIndex][barIndex]
            let segmentColor = colors[partIndex]
            
            ForEach(0..<barSegments.count, id: \.self) { staveIndex in
                ForEach(0..<barSegments[staveIndex].count, id: \.self) { segmentIndex in
                    let segment = barSegments[staveIndex][segmentIndex]
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
}

#Preview {
    RollBarView(segments: [], barIndex: 0, barWidth: 0, rowHeight: 0, colors: [])
}

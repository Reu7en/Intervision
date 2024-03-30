//
//  RollBarView.swift
//  Intervision
//
//  Created by Reuben on 24/02/2024.
//

import SwiftUI

struct RollBarView: View {
    
    @StateObject var rollViewModel: RollViewModel
    
    let segments: [[[[Segment]]]]
    let barIndex: Int
    let barWidth: CGFloat
    let rowHeight: CGFloat
    let colors: [Color]
    let showDynamics: Bool
    
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
                    let brightness = segment.dynamic?.brightness ?? 0.3
                    let saturation = segment.dynamic?.saturation ?? 0.7
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(segment.isSelected ? Color.white : Color.black, style: segment.isSelected ? StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5]) : StrokeStyle())
                        .background (
                            RoundedRectangle(cornerRadius: 20)
                                .fill(segmentColor)
                                .brightness(showDynamics ? brightness : 0.0)
                                .saturation(showDynamics ? saturation : 1.0)
                        )
                        .frame(width: width, height: rowHeight)
                        .position(x: xPosition + (width / 2), y: yPosition + (rowHeight / 2))
                        .onTapGesture {
                            guard let currentEvent = NSApp.currentEvent else { return }
                            rollViewModel.handleSegmentClicked(segment: segment, isCommandKeyDown: currentEvent.modifierFlags.contains(.command))
                        }
                }
            }
        }
    }
}

//#Preview {
//    RollBarView(rollViewModel: RollViewModel(), segments: [], barIndex: 0, barWidth: 0, rowHeight: 0, colors: [], showDynamics: false)
//}

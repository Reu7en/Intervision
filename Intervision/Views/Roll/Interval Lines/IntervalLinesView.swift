//
//  IntervalLinesView.swift
//  Intervision
//
//  Created by Reuben on 01/03/2024.
//

import SwiftUI

struct IntervalLinesView: View {
    
    @StateObject var intervalLinesViewModel: IntervalLinesViewModel
    
    var body: some View {
        if let harmonicLines = intervalLinesViewModel.harmonicLines {
            ForEach(0..<harmonicLines.count, id: \.self) { lineIndex in
                Path { path in
                    path.move(to: harmonicLines[lineIndex].startPoint)
                    path.addLine(to: harmonicLines[lineIndex].endPoint)
                }
                .stroke(harmonicLines[lineIndex].color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .shadow(color: Color.black.opacity(0.75), radius: 5, x: 0, y: 0)
            }
        }
        
        if let melodicLines = intervalLinesViewModel.melodicLines {
            ForEach(0..<melodicLines.count, id: \.self) { lineIndex in
                Path { path in
                    path.move(to: melodicLines[lineIndex].startPoint)
                    path.addLine(to: melodicLines[lineIndex].endPoint)
                }
                .stroke(melodicLines[lineIndex].color, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, dash: [5]))
                .shadow(color: Color.black.opacity(0.75), radius: 5, x: 0, y: 0)
                .zIndex(.infinity)
            }
        }
    }
}

#Preview {
    IntervalLinesView(intervalLinesViewModel: IntervalLinesViewModel(segments: [], harmonicIntervalLinesType: .none, showMelodicIntervalLines: false, barIndex: 0, barWidth: 0, rowHeight: 0))
}

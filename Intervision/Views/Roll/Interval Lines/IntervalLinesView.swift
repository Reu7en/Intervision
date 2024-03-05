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
                .stroke(harmonicLines[lineIndex].color, lineWidth: 3)
//                .stroke(harmonicLines[lineIndex].color, style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5]))
            }
        }
        
        if let melodicLines = intervalLinesViewModel.melodicLines {
            ForEach(0..<melodicLines.count, id: \.self) { lineIndex in
                Path { path in
                    path.move(to: melodicLines[lineIndex].0[0])
                    path.addLine(to: melodicLines[lineIndex].0[1])
                }
                .stroke(melodicLines[lineIndex].1)
            }
        }
    }
}

#Preview {
    IntervalLinesView(intervalLinesViewModel: IntervalLinesViewModel(segments: [], harmonicIntervalLinesType: .none, melodicIntervalLinesType: .none, barIndex: 0, barWidth: 0, rowHeight: 0))
}

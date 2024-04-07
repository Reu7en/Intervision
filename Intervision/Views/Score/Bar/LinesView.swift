//
//  LinesView.swift
//  Intervision
//
//  Created by Reuben on 06/04/2024.
//

import SwiftUI

struct LinesView: View {
    
    @ObservedObject var linesViewModel: LinesViewModel
    
    var body: some View {
        ForEach(0..<linesViewModel.beamLines.count, id: \.self) { lineIndex in
            let line = linesViewModel.beamLines[lineIndex]
            
            Path { path in
                path.move(to: line.startPoint)
                path.addLine(to: line.endPoint)
            }
            .stroke(line.color, lineWidth: linesViewModel.beamThickness)
        }
        
        ForEach(0..<linesViewModel.stemLines.count, id: \.self) { lineIndex in
            let line = linesViewModel.stemLines[lineIndex]
            
            Path { path in
                path.move(to: line.startPoint)
                path.addLine(to: line.endPoint)
            }
            .stroke(line.color, lineWidth: linesViewModel.stemThickness)
        }
        
        ForEach(0..<linesViewModel.timeModifications.count, id: \.self) { timeModificationIndex in
            let timeModification = linesViewModel.timeModifications[timeModificationIndex]
            
            Text("\(timeModification.1)")
                .frame(width: linesViewModel.noteSize * 1.5)
                .foregroundStyle(Color.black)
                .fontWeight(.bold)
                .position(timeModification.0)
        }
    }
}

#Preview {
    GeometryReader { geometry in
        LinesView(linesViewModel: LinesViewModel(beamGroups: [], positions: [], middleStaveNote: nil, barGeometry: geometry, beatGeometry: geometry, noteSize: .zero))
    }
}

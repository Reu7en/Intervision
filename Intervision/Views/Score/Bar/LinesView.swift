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
        
        ForEach(0..<linesViewModel.tailLines.count, id: \.self) { lineIndex in
            let line = linesViewModel.tailLines[lineIndex]
            
            Path { path in
                path.move(to: line.startPoint)
                path.addLine(to: line.endPoint)
            }
            .stroke(line.color, lineWidth: linesViewModel.tailThickness)
        }
        
        ForEach(0..<linesViewModel.ledgerLines.count, id: \.self) { lineIndex in
            let line = linesViewModel.ledgerLines[lineIndex]
            
            Path { path in
                path.move(to: line.startPoint)
                path.addLine(to: line.endPoint)
            }
            .stroke(line.color, lineWidth: linesViewModel.ledgerThickness)
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

struct InternalRoundedLine: Shape {
    var startPoint: CGPoint
    var endPoint: CGPoint
    var lineWidth: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let halfLineWidth = lineWidth / 2.0
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let angle = atan2(dy, dx)
        
        let newStartPoint = CGPoint(x: startPoint.x + cos(angle) * halfLineWidth,
                                    y: startPoint.y + sin(angle) * halfLineWidth)
        let newEndPoint = CGPoint(x: endPoint.x - cos(angle) * halfLineWidth,
                                  y: endPoint.y - sin(angle) * halfLineWidth)
        
        path.move(to: newStartPoint)
        path.addLine(to: newEndPoint)
        
        return path
    }
}

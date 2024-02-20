//
//  NoteTailView.swift
//  Intervision
//
//  Created by Reuben on 17/02/2024.
//

import SwiftUI

struct NoteTailView: View {
    
    let furthestPosition: CGPoint
    let duration: Note.Duration
    let stemLength: CGFloat
    let direction: BeamViewModel.Direction
    let xOffset: CGFloat
    let scale: CGFloat
    
    var numberOfTails: Int {
        switch duration {
        case .eighth: return 1
        case .sixteenth: return 2
        case .thirtySecond: return 3
        case .sixtyFourth: return 4
        default: return 0
        }
    }
    
    var tailStartPositions: [CGPoint] {
        var positions: [CGPoint] = []
        let tailSpacing = stemLength / 6.0
        let stemTipPosition = CGPoint(x: furthestPosition.x + xOffset, y: (direction == .Upward) ? furthestPosition.y - stemLength + stemLength / 50 : furthestPosition.y + stemLength - stemLength / 50)
        
        if numberOfTails > 0 {
            positions.append(stemTipPosition)
        }
        
        if numberOfTails > 1 {
            for i in 1..<numberOfTails {
                let yOffset = (direction == .Upward) ? CGFloat(i) * tailSpacing : -CGFloat(i) * tailSpacing
                let position = CGPoint(x: stemTipPosition.x, y: stemTipPosition.y + yOffset)
                positions.append(position)
            }
        }
        
        return positions
    }
    
    var body: some View {
        
        let tailThickness: CGFloat = 7 * scale
        
        ZStack {
            ForEach(0..<tailStartPositions.count, id: \.self) { positionIndex in
                let startPosition = tailStartPositions[positionIndex]
                let angle: Angle = (direction == .Upward) ? .degrees(45) : .degrees(-45)
                let lineEndPosition = CGPoint(x: Double(startPosition.x) + Double(stemLength / 2.25) * cos(angle.radians),
                                              y: Double(startPosition.y) + Double(stemLength / 2.25) * sin(angle.radians))
                
                Path { path in
                    path.move(to: startPosition)
                    path.addLine(to: lineEndPosition)
                }
                .stroke(Color.black, lineWidth: tailThickness)
            }
        }
    }
}

#Preview {
    NoteTailView(furthestPosition: CGPoint(x: 0, y: 0), duration: Note.Duration.eighth, stemLength: 10, direction: .Upward, xOffset: 0, scale: 1.0)
}

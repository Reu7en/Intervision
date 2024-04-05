//
//  BeamLineView.swift
//  Intervision
//
//  Created by Reuben on 17/02/2024.
//

import SwiftUI

struct BeamLineView: View {
    
    let furthestStartPosition: CGPoint
    let furthestEndPosition: CGPoint
    let durations: [Note.Duration]
    let timeModification: Note.TimeModification?
    let stemLength: CGFloat
    let direction: BeamViewModel.Direction
    let xOffset: CGFloat
    let scale: CGFloat
    
    var numberOfBeamLines: [Int] {
        return durations.map { duration in
            switch duration {
            case .eighth: return 1
            case .sixteenth: return 2
            case .thirtySecond: return 3
            case .sixtyFourth: return 4
            default: return 0
            }
        }
    }
    
    var beamStartPositions: [[CGPoint]] {
        var positions: [[CGPoint]] = []
        let beamSpacing = stemLength / 6.0
        let startStemTipPosition = CGPoint(x: furthestStartPosition.x + xOffset, y: (direction == .Upward) ? furthestStartPosition.y - stemLength + stemLength / 50 : furthestStartPosition.y + stemLength - stemLength / 50)
        let endStemTipPosition = CGPoint(x: furthestEndPosition.x + xOffset, y: (direction == .Upward) ? furthestEndPosition.y - stemLength + stemLength / 50 : furthestEndPosition.y + stemLength - stemLength / 50)
        
        for i in 0..<durations.count {
            var chordPositions: [CGPoint] = []
            let t = CGFloat(i) / CGFloat(durations.count - 1)
            let x = startStemTipPosition.x + t * (endStemTipPosition.x - startStemTipPosition.x)
            let y = startStemTipPosition.y + t * (endStemTipPosition.y - startStemTipPosition.y)
            let stemTipPosition = CGPoint(x: x, y: y)
            
            if numberOfBeamLines[i] > 0 {
                chordPositions.append(stemTipPosition)
            }
            
            if numberOfBeamLines[i] > 1 {
                for i in 1..<numberOfBeamLines[i] {
                    let yOffset = (direction == .Upward) ? CGFloat(i) * beamSpacing : -CGFloat(i) * beamSpacing
                    let position = CGPoint(x: stemTipPosition.x, y: stemTipPosition.y + yOffset)
                    chordPositions.append(position)
                }
            }
            
            positions.append(chordPositions)
        }
        
        return positions
    }
    
    var forwardBeamAngle: Angle {
        let deltaX = furthestEndPosition.x - furthestStartPosition.x
        let deltaY = furthestEndPosition.y - furthestStartPosition.y
        let angle = atan2(deltaY, deltaX)
        return Angle(radians: angle)
    }

    var backwardBeamAngle: Angle {
        return forwardBeamAngle + Angle(degrees: 180)
    }
    
    var beamSegmentLength: CGFloat {
        let deltaX = furthestEndPosition.x - furthestStartPosition.x
        let deltaY = furthestEndPosition.y - furthestStartPosition.y
        let beamLength = sqrt(deltaX * deltaX + deltaY * deltaY)
        return beamLength / CGFloat((durations.count - 1) * 2)
    }
    
    var body: some View {
        
        let beamThickness: CGFloat = 11 * scale
        
        ZStack {
            ForEach(0..<beamStartPositions.count, id: \.self) { chordIndex in
                ForEach(0..<beamStartPositions[chordIndex].count, id: \.self) { beamIndex in
                    let beamPosition = beamStartPositions[chordIndex][beamIndex]
                    
                    let forwardLineEnd = CGPoint(x: beamPosition.x + CGFloat(cos(forwardBeamAngle.radians)) * beamSegmentLength,
                                                 y: beamPosition.y + CGFloat(sin(forwardBeamAngle.radians)) * beamSegmentLength)
                                                        
                    let backwardLineEnd = CGPoint(x: beamPosition.x + CGFloat(cos(backwardBeamAngle.radians)) * beamSegmentLength,
                                                  y: beamPosition.y + CGFloat(sin(backwardBeamAngle.radians)) * beamSegmentLength)
                    
                    if chordIndex != beamStartPositions.count - 1 {
                        Path { path in
                            path.move(to: beamPosition)
                            path.addLine(to: forwardLineEnd)
                        }
                        .stroke(Color.black, lineWidth: beamThickness)
                    }
                    
                    if chordIndex != 0 {
                        Path { path in
                            path.move(to: beamPosition)
                            path.addLine(to: backwardLineEnd)
                        }
                        .stroke(Color.black, lineWidth: beamThickness)
                    }
                }
            }
            
            let midpointX = (furthestStartPosition.x + furthestEndPosition.x) / 2
            let midpointY = (furthestStartPosition.y + furthestEndPosition.y) / 2
            
            let timeModificationValue: Int? = {
                if let timeModification = timeModification, case .custom(let actual, _, _) = timeModification {
                    return actual
                }
                
                return nil
            }()
            
            if let timeModificationValue = timeModificationValue {
                let numberPosition = CGPoint(x: midpointX + xOffset, y: direction == .Upward ? midpointY - stemLength - 50 * scale : midpointY + stemLength + 50 * scale)
                
                Text("\(timeModificationValue)")
                    .font(Font.system(size: 50 * scale))
                    .foregroundStyle(Color.black)
                    .position(numberPosition)
                
                if numberOfBeamLines.allSatisfy({ $0 == 0 }) {
                    let lineStart = CGPoint(x: furthestStartPosition.x + xOffset + CGFloat(cos(backwardBeamAngle.radians)) * 20 * scale, y: direction == .Upward ? furthestStartPosition.y - stemLength - 25 * scale - CGFloat(sin(backwardBeamAngle.radians)) * 20 * scale : furthestStartPosition.y + stemLength + 25 * scale + CGFloat(sin(backwardBeamAngle.radians)) * 20 * scale)
                    let lineEnd = CGPoint(x: furthestEndPosition.x + xOffset + CGFloat(cos(forwardBeamAngle.radians)) * 20 * scale, y: direction == .Upward ? furthestEndPosition.y - stemLength - 25 * scale - CGFloat(sin(forwardBeamAngle.radians)) * 20 * scale : furthestEndPosition.y + stemLength + 25 * scale + CGFloat(sin(forwardBeamAngle.radians)) * 20 * scale)
                    
                    let lineStartEdge = CGPoint(x: furthestStartPosition.x + xOffset + CGFloat(cos(backwardBeamAngle.radians)) * 20 * scale, y: direction == .Upward ? furthestStartPosition.y - stemLength : furthestStartPosition.y + stemLength)
                    
                    let lineEndEdge = CGPoint(x: furthestEndPosition.x + xOffset + CGFloat(cos(forwardBeamAngle.radians)) * 20 * scale, y: direction == .Upward ? furthestEndPosition.y - stemLength : furthestEndPosition.y + stemLength)
                    
                    Path { path in
                        path.move(to: lineStart)
                        path.addLine(to: lineEnd)
                        
                        path.move(to: lineStart)
                        path.addLine(to: lineStartEdge)
                        
                        path.move(to: lineEnd)
                        path.addLine(to: lineEndEdge)
                    }
                    .stroke(Color.black, lineWidth: beamThickness / 2)
                }
            }
        }
//        .border(.blue)
    }
}

#Preview {
    BeamLineView(furthestStartPosition: CGPoint(x: 0, y: 0), furthestEndPosition: CGPoint(x: 0, y: 0), durations: [], timeModification: nil, stemLength: 10, direction: .Upward, xOffset: 0, scale: 1.0)
}

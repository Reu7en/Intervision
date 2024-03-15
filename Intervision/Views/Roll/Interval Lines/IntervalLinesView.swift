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
                let line = harmonicLines[lineIndex]
                
                if line.inversionType == .Inverted && intervalLinesViewModel.showInvertedIntervals && intervalLinesViewModel.showZigZags {
                    ZigzagLine(startPoint: line.startPoint, endPoint: line.endPoint, amplitude: intervalLinesViewModel.barWidth / 256)
                        .stroke(line.color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .shadow(color: Color.black.opacity(0.75), radius: 5, x: 0, y: 0)
                } else {
                    Path { path in
                        path.move(to: line.startPoint)
                        path.addLine(to: line.endPoint)
                    }
                    .stroke(line.color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .shadow(color: Color.black.opacity(0.75), radius: 5, x: 0, y: 0)
                }
            }
        }
        
        if let melodicLines = intervalLinesViewModel.melodicLines {
            ForEach(0..<melodicLines.count, id: \.self) { lineIndex in
                let line = melodicLines[lineIndex]
                
                if line.inversionType == .Inverted && intervalLinesViewModel.showInvertedIntervals && intervalLinesViewModel.showZigZags {
                    ZigzagLine(startPoint: line.startPoint, endPoint: line.endPoint, amplitude: intervalLinesViewModel.barWidth / 256)
                        .stroke(line.color, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, dash: [4]))
                        .shadow(color: Color.black, radius: 5, x: 0, y: 0)
                        .zIndex(.infinity)
                } else {
                    Path { path in
                        path.move(to: line.startPoint)
                        path.addLine(to: line.endPoint)
                    }
                    .stroke(line.color, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, dash: [4]))
                    .shadow(color: Color.black, radius: 5, x: 0, y: 0)
                    .zIndex(.infinity)
                }
            }
        }
    }
}

extension IntervalLinesView {
    struct ZigzagLine: Shape {
        var startPoint: CGPoint
        var endPoint: CGPoint
        var amplitude: CGFloat

        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: startPoint)

            let deltaX = endPoint.x - startPoint.x
            let deltaY = endPoint.y - startPoint.y
            let segmentLength = hypot(deltaX, deltaY)
            let segments = Int(segmentLength / 10) // Adjust segment length as per preference
            let angle = atan2(deltaY, deltaX)

            for i in 1..<segments {
                let x = startPoint.x + cos(angle) * CGFloat(i) * 10
                let y = startPoint.y + sin(angle) * CGFloat(i) * 10
                let point = CGPoint(x: x, y: y)

                let perpendicularAngle = angle + .pi / 2
                let offset = (i % 2 == 0 ? amplitude : -amplitude)
                let offsetX = offset * cos(perpendicularAngle)
                let offsetY = offset * sin(perpendicularAngle)

                let zigzagPoint = CGPoint(x: point.x + offsetX, y: point.y + offsetY)
                path.addLine(to: zigzagPoint)
            }

            path.addLine(to: endPoint)
            return path
        }
    }
}

extension Color {
    func inverseColor() -> Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var opacity: CGFloat = 0
        
        NSColor(self).getRed(&red, green: &green, blue: &blue, alpha: &opacity)
        
        let invertedRed = 1.0 - red
        let invertedGreen = 1.0 - green
        let invertedBlue = 1.0 - blue
        
        return Color(red: Double(invertedRed), green: Double(invertedGreen), blue: Double(invertedBlue), opacity: Double(opacity))
    }
}

#Preview {
    IntervalLinesView(intervalLinesViewModel: IntervalLinesViewModel(segments: [], groups: [], harmonicIntervalLinesType: .none, showMelodicIntervalLines: false, barIndex: 0, barWidth: 0, rowWidth: 0, rowHeight: 0, harmonicIntervalLineColors: [], melodicIntervalLineColors: [], showInvertedIntervals: false, showZigZags: false))
}

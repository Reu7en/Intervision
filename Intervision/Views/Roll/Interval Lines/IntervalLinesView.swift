//
//  IntervalLinesView.swift
//  Intervision
//
//  Created by Reuben on 01/03/2024.
//

import SwiftUI

#if os(macOS)
import Cocoa
#elseif os(iOS)
import UIKit
#endif

struct IntervalLinesView: View {
    
    @EnvironmentObject var screenSizeViewModel: ScreenSizeViewModel
    
    @StateObject var intervalLinesViewModel: IntervalLinesViewModel
    
    var body: some View {
        let lineWidth: CGFloat = screenSizeViewModel.getEquivalentValue(5)
        
        ForEach(0..<intervalLinesViewModel.harmonicLines.count, id: \.self) { lineIndex in
            let line = intervalLinesViewModel.harmonicLines[lineIndex]
            
            if line.dotted {
                if line.inversionType == .Inverted && intervalLinesViewModel.showInvertedIntervals && intervalLinesViewModel.showZigZags {
                    ZigzagLine(startPoint: line.startPoint, endPoint: line.endPoint, amplitude: lineWidth * 2)
                        .stroke(line.color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, dash: [0, lineWidth * 2]))
                        .shadow(color: Color.black.opacity(0.75), radius: lineWidth, x: 0, y: 0)
                } else {
                    Path { path in
                        path.move(to: line.startPoint)
                        path.addLine(to: line.endPoint)
                    }
                    .stroke(line.color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round, dash: [0, lineWidth * 2]))
                    .shadow(color: Color.black.opacity(0.75), radius: lineWidth, x: 0, y: 0)
                }
            } else {
                if line.inversionType == .Inverted && intervalLinesViewModel.showInvertedIntervals && intervalLinesViewModel.showZigZags {
                    ZigzagLine(startPoint: line.startPoint, endPoint: line.endPoint, amplitude: lineWidth * 2)
                        .stroke(line.color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                        .shadow(color: Color.black.opacity(0.75), radius: lineWidth, x: 0, y: 0)
                } else {
                    Path { path in
                        path.move(to: line.startPoint)
                        path.addLine(to: line.endPoint)
                    }
                    .stroke(line.color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    .shadow(color: Color.black.opacity(0.75), radius: lineWidth, x: 0, y: 0)
                }
            }
        }
        
        ForEach(0..<intervalLinesViewModel.melodicLines.count, id: \.self) { lineIndex in
            let line = intervalLinesViewModel.melodicLines[lineIndex]
            
            if line.dotted {
                if line.inversionType == .Inverted && intervalLinesViewModel.showInvertedIntervals && intervalLinesViewModel.showZigZags {
                    ZigzagLine(startPoint: line.startPoint, endPoint: line.endPoint, amplitude: lineWidth * 2)
                        .stroke(line.color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, dash: [0, lineWidth * 2]))
                        .shadow(color: Color.black.opacity(0.75), radius: lineWidth, x: 0, y: 0)
                } else {
                    Path { path in
                        path.move(to: line.startPoint)
                        path.addLine(to: line.endPoint)
                    }
                    .stroke(line.color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round, dash: [0, lineWidth * 2]))
                    .shadow(color: Color.black.opacity(0.75), radius: lineWidth, x: 0, y: 0)
                }
            } else {
                if line.inversionType == .Inverted && intervalLinesViewModel.showInvertedIntervals && intervalLinesViewModel.showZigZags {
                    ZigzagLine(startPoint: line.startPoint, endPoint: line.endPoint, amplitude: lineWidth * 2)
                        .stroke(line.color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                        .shadow(color: Color.black.opacity(0.75), radius: lineWidth, x: 0, y: 0)
                } else {
                    Path { path in
                        path.move(to: line.startPoint)
                        path.addLine(to: line.endPoint)
                    }
                    .stroke(line.color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    .shadow(color: Color.black.opacity(0.75), radius: lineWidth, x: 0, y: 0)
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
            let segments = Int(segmentLength / 10)
            let angle = atan2(deltaY, deltaX)

            if segments > 0 {
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
        
        #if os(macOS)
        NSColor(self).getRed(&red, green: &green, blue: &blue, alpha: &opacity)
        #elseif os(iOS)
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &opacity)
        #endif
        
        let invertedRed = 1.0 - red
        let invertedGreen = 1.0 - green
        let invertedBlue = 1.0 - blue
        
        return Color(red: Double(invertedRed), green: Double(invertedGreen), blue: Double(invertedBlue), opacity: Double(opacity))
    }
}

#Preview {
    IntervalLinesView(intervalLinesViewModel: IntervalLinesViewModel(segments: [], parts: [], groups: [], harmonicIntervalLinesType: .none, showMelodicIntervalLines: false, barIndex: 0, barWidth: 0, rowWidth: 0, rowHeight: 0, harmonicIntervalLineColors: [], melodicIntervalLineColors: [], viewableMelodicLines: [], showInvertedIntervals: false, showZigZags: false, testing: false))
        .environmentObject(ScreenSizeViewModel())
}

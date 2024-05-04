//
//  LineKeyView.swift
//  Intervision
//
//  Created by Reuben on 01/05/2024.
//

import SwiftUI

struct LineKeyView: View {
    
    @EnvironmentObject var screenSizeViewModel: ScreenSizeViewModel
    
    let color: Color
    let label: String
    let showZigZags: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Text(label)
                    .equivalentFont()
                    .fontWeight(.semibold)
                
                if showZigZags {
                    ZStack {
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: geometry.size.height / 3))
                            path.addLine(to: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 3))
                        }
                        .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .shadow(color: Color.black.opacity(0.75), radius: 5, x: 0, y: 0)
                        
                        IntervalLinesView.ZigzagLine(startPoint: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 3), endPoint: CGPoint(x: geometry.size.width, y: geometry.size.height / 3), amplitude: geometry.size.height / 10)
                            .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .shadow(color: Color.black.opacity(0.75), radius: 5, x: 0, y: 0)
                    }
                } else {
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: geometry.size.height / 3))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 3))
                    }
                    .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .shadow(color: Color.black.opacity(0.75), radius: 5, x: 0, y: 0)
                }
            }
        }
    }
}

#Preview {
    LineKeyView(color: .clear, label: "", showZigZags: false)
        .environmentObject(ScreenSizeViewModel())
}

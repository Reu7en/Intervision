//
//  StaveView.swift
//  Intervision
//
//  Created by Reuben on 15/02/2024.
//

import SwiftUI

struct StaveView: View {
    let rows: Int
    let ledgerLines: Int
    let geometry: GeometryProxy
    let lineWidth: CGFloat
    
    var body: some View {
        ForEach(0..<rows, id: \.self) { index in
            let shouldDrawHorizontalLine = (index % 2 != 0) && (index > ledgerLines * 2 - 1) && (index < rows - ledgerLines * 2 - 1)
            let shouldDrawVerticalLine = (index % 2 != 0) && (index > ledgerLines * 2 - 1) && (index < rows - ledgerLines * 2 - 2)
            let yPosition = CGFloat(index) * (geometry.size.height / CGFloat(rows - 1))
            
            // Horizontal Lines
            if shouldDrawHorizontalLine {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: yPosition))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: yPosition))
                }
                .stroke(Color.black, lineWidth: lineWidth)
            }
            
            // Vertical Lines
            if shouldDrawVerticalLine {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: yPosition))
                    path.addLine(to: CGPoint(x: 0, y: yPosition + 2 * (geometry.size.height / CGFloat(rows - 1))))
                    
                    path.move(to: CGPoint(x: geometry.size.width, y: yPosition))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: yPosition + 2 * (geometry.size.height / CGFloat(rows - 1))))
                }
                .stroke(Color.black, lineWidth: lineWidth)
            }
        }
    }
}

#Preview {
    GeometryReader { geometry in
        StaveView(rows: 23, ledgerLines: 3, geometry: geometry, lineWidth: 2)
    }
}

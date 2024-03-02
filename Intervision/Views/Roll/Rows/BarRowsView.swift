//
//  BarRowsView.swift
//  Intervision
//
//  Created by Reuben on 01/03/2024.
//

import SwiftUI

struct BarRowsView: View {
    
    let rows: Int
    let rowWidth: CGFloat
    let rowHeight: CGFloat
    let beats: Int
    
    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(0..<rows, id: \.self) { rowIndex in
                ZStack {
                    Rectangle()
                        .fill([1, 3, 5, 8, 10].contains(rowIndex % 12) ? Color.black.opacity(0.5) : Color.black.opacity(0.125))
                        .frame(height: rowHeight)
                        .border(Color.black.opacity(0.25))
                    
                    ForEach(0..<beats, id: \.self) { beatIndex in
                        Path { path in
                            let xPosition = CGFloat(beatIndex) * (rowWidth / CGFloat(beats))
                            
                            path.move(to: CGPoint(x: xPosition, y: 0))
                            path.addLine(to: CGPoint(x: xPosition, y: rowHeight))
                        }
                        .stroke(Color.black.opacity(beatIndex == 0 ? 1.0 : 0.25))
                    }
                }
            }
        }
    }
}

#Preview {
    BarRowsView(rows: 1, rowWidth: 1, rowHeight: 1, beats: 1)
}

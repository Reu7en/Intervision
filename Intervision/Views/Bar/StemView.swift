//
//  StemView.swift
//  Intervision
//
//  Created by Reuben on 17/02/2024.
//

import SwiftUI

struct StemView: View {
    
    let position: CGPoint
    let direction: BeamViewModel.Direction
    let stemLength: CGFloat
    let xOffset: CGFloat
    let scale: CGFloat
    
    var body: some View {
        
        let stemThickness: CGFloat = 5 * scale
        let stemY = (direction == .Upward) ? position.y - stemLength : position.y + stemLength
        
        Path { path in
            path.move(to: CGPoint(x: position.x + xOffset, y: position.y))
            path.addLine(to: CGPoint(x: position.x + xOffset, y: stemY))
        }
        .stroke(Color.black, lineWidth: stemThickness)
    }
}

#Preview {
    StemView(position: CGPoint(x: 0, y: 0), direction: .Upward, stemLength: 10, xOffset: 0, scale: 1.0)
}

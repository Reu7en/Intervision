//
//  BarRowsView.swift
//  Intervision
//
//  Created by Reuben on 01/03/2024.
//

import SwiftUI
import Cocoa

struct BarRowsView: View {
    
    let rows: Int
    let rowWidth: CGFloat
    let rowHeight: CGFloat
    let beats: Int
    
    var body: some View {
        let image = Image(nsImage: renderContent())
        return image
    }
    
    private func renderContent() -> NSImage {
        let imageSize = CGSize(width: rowWidth, height: rowHeight * CGFloat(rows))
        let image = NSImage(size: imageSize)
        
        image.lockFocus()
        
        for rowIndex in 0..<rows {
            let rect = CGRect(x: 0, y: CGFloat(rowIndex) * rowHeight, width: rowWidth, height: rowHeight)
            let fillColor = [1, 3, 5, 8, 10].contains(rowIndex % 12) ? NSColor.black.withAlphaComponent(0.5) : NSColor.black.withAlphaComponent(0.125)
            fillColor.setFill()
            rect.fill()
            
            let borderPath = NSBezierPath(rect: rect)
            borderPath.lineWidth = 1.0
            NSColor.black.withAlphaComponent(0.375).setStroke()
            borderPath.stroke()
        }
        
        for beatIndex in 1..<beats {
            let xPosition = CGFloat(beatIndex) * (rowWidth / CGFloat(beats))
            let path = NSBezierPath()
            path.move(to: CGPoint(x: xPosition, y: 0))
            path.line(to: CGPoint(x: xPosition, y: rowHeight * CGFloat(rows)))
            NSColor.black.withAlphaComponent(0.25).setStroke()
            path.stroke()
        }
        
        let borderPath = NSBezierPath(rect: NSRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        borderPath.lineWidth = 1.0
        NSColor.black.withAlphaComponent(0.75).setStroke()
        borderPath.stroke()
        
        image.unlockFocus()
        
        return image
    }
}

#Preview {
    BarRowsView(rows: 1, rowWidth: 1, rowHeight: 1, beats: 1)
}

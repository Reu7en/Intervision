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
    let viewType: BarRowsView.ViewType
    
    var body: some View {
        let image = Image(nsImage: renderContent(viewType))
        return image
    }
    
    private func renderContent(_ viewType: BarRowsView.ViewType) -> NSImage {
        let imageSize = CGSize(width: rowWidth, height: rowHeight * CGFloat(rows))
        let image = NSImage(size: imageSize)
        
        image.lockFocus()
        
        for rowIndex in 0..<rows {
            let rect = CGRect(x: 0, y: CGFloat(rowIndex) * rowHeight, width: rowWidth, height: rowHeight)
            var fillColor = NSColor.black.withAlphaComponent(0.125)
            
            switch viewType {
            case .Piano:
                fillColor = [1, 3, 6, 8, 10].contains(rowIndex % 12) ? NSColor.black.withAlphaComponent(0.5) : NSColor.black.withAlphaComponent(0.125)
            case .TwoSpaced:
                fillColor = rowIndex % 2 == 0 ? NSColor.black.withAlphaComponent(0.5) : NSColor.black.withAlphaComponent(0.125)
            case .ThreeSpaced:
                fillColor = rowIndex % 3 == 0 ? NSColor.black.withAlphaComponent(0.5) : NSColor.black.withAlphaComponent(0.125)
            case .FourSpaced:
                fillColor = rowIndex % 4 == 0 ? NSColor.black.withAlphaComponent(0.5) : NSColor.black.withAlphaComponent(0.125)
            case .None:
                fillColor = NSColor.black.withAlphaComponent(0.125)
            }
            
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

extension BarRowsView {
    enum ViewType {
        case Piano
        case TwoSpaced
        case ThreeSpaced
        case FourSpaced
        case None
    }
}

#Preview {
    BarRowsView(rows: 12, rowWidth: 500, rowHeight: 50, beats: 1, viewType: .None)
}

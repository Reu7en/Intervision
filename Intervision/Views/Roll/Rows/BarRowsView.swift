//
//  BarRowsView.swift
//  Intervision
//
//  Created by Reuben on 01/03/2024.
//

import SwiftUI

#if os(macOS)
import Cocoa
import AppKit
#elseif os(iOS)
import UIKit
#endif

struct BarRowsView: View {
    
    let rows: Int
    let rowWidth: CGFloat
    let rowHeight: CGFloat
    let beats: Int
    let viewType: BarRowsView.ViewType
    let image: Bool
    
    var body: some View {
        if image {
            renderImage()
        } else {
            renderView()
        }
    }
    
    @ViewBuilder
    private func renderView() -> some View {
        HStack(spacing: 0) {
            ForEach(0..<beats, id: \.self) { _ in
                VStack(spacing: 0) {
                    ForEach(0..<rows, id: \.self) { rowIndex in
                        Rectangle()
                            .frame(width: rowWidth / CGFloat(beats), height: rowHeight)
                            .foregroundStyle(fillColor(for: rowIndex))
                            .border(Color.black)
                    }
                }
                .border(Color.black)
            }
        }
    }
    
    #if os(macOS)
    private func renderImage() -> some View {
        Image(nsImage: renderContent(viewType))
    }
    
    private func renderContent(_ viewType: BarRowsView.ViewType) -> NSImage {
        let imageSize = CGSize(width: rowWidth, height: rowHeight * CGFloat(rows))
        let image = NSImage(size: imageSize)
        
        image.lockFocus()
        
        for rowIndex in 0..<rows {
            let rect = CGRect(x: 0, y: rowHeight - CGFloat(rowIndex) * rowHeight, width: rowWidth, height: rowHeight)
            let fillColor = NSColor(cgColor: fillColor(for: rowIndex).cgColor ?? CGColor(red: 0, green: 0, blue: 0, alpha: 0.125)) ?? NSColor.black.withAlphaComponent(0.125)
            
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
    #elseif os(iOS)
    private func renderImage() -> some View {
        Image(uiImage: renderContent(viewType))
    }

    private func renderContent(_ viewType: BarRowsView.ViewType) -> UIImage {
        let imageSize = CGSize(width: rowWidth, height: rowHeight * CGFloat(rows))
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        let image = renderer.image { context in
            for rowIndex in 0..<rows {
                let rect = CGRect(x: 0, y: rowHeight - CGFloat(rowIndex) * rowHeight, width: rowWidth, height: rowHeight)
                let fillColor = fillColor(for: rowIndex).cgColor ?? UIColor.black.withAlphaComponent(0.125).cgColor
                context.cgContext.setFillColor(fillColor)
                context.fill(rect)
                
                let borderPath = UIBezierPath(rect: rect)
                borderPath.lineWidth = 1.0
                UIColor.black.withAlphaComponent(0.375).setStroke()
                borderPath.stroke()
            }
            
            for beatIndex in 1..<beats {
                let xPosition = CGFloat(beatIndex) * (rowWidth / CGFloat(beats))
                let path = UIBezierPath()
                path.move(to: CGPoint(x: xPosition, y: 0))
                path.addLine(to: CGPoint(x: xPosition, y: rowHeight * CGFloat(rows)))
                UIColor.black.withAlphaComponent(0.25).setStroke()
                path.stroke()
            }
            
            let borderPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
            borderPath.lineWidth = 1.0
            UIColor.black.withAlphaComponent(0.75).setStroke()
            borderPath.stroke()
        }
        return image
    }
    #endif
    
    private func fillColor(for rowIndex: Int) -> Color {
        switch viewType {
        case .Piano:
            return [1, 3, 5, 8, 10].contains(rowIndex % 12) ? Color.black.opacity(0.5) : Color.black.opacity(0.125)
        case .TwoSpaced:
            return rowIndex % 2 == 0 ? Color.black.opacity(0.5) : Color.black.opacity(0.125)
        case .ThreeSpaced:
            return rowIndex % 3 == 0 ? Color.black.opacity(0.5) : Color.black.opacity(0.125)
        case .FourSpaced:
            return rowIndex % 4 == 0 ? Color.black.opacity(0.5) : Color.black.opacity(0.125)
        case .None:
            return Color.black.opacity(0.125)
        }
    }
}

extension BarRowsView {
    enum ViewType: String, CaseIterable {
        case Piano
        case TwoSpaced = "Two Spaced"
        case ThreeSpaced = "Three Spaced"
        case FourSpaced = "Four Spaced"
        case None = "No Spacing"
    }
}

#Preview {
    BarRowsView(rows: 12, rowWidth: 500, rowHeight: 50, beats: 1, viewType: .None, image: true)
}

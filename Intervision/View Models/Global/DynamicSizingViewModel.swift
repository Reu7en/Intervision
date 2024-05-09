//
//  ScreenSizeViewModel.swift
//  Intervision
//
//  Created by Reuben on 02/05/2024.
//

import Foundation
import SwiftUI

class DynamicSizingViewModel: ObservableObject {
    
    @Published var viewSize: CGSize
    
    let referenceViewSize: CGSize
    let referencePaddingAmount: CGFloat
    let referenceFontSize: CGFloat
    
    init (
        viewSize: CGSize = .zero,
        referenceViewSize: CGSize = CGSize(width: 1920, height: 1080),
        referencePaddingAmount: CGFloat = 8,
        referenceFontSize: CGFloat = 32
    ) {
        self.viewSize = viewSize
        
        if referenceViewSize == .zero || referenceViewSize.width == .zero || referenceViewSize.height == .zero {
            self.referenceViewSize = CGSize(width: 1920, height: 1080) // Fallback to prevent divide-by-zero errors
        } else {
            self.referenceViewSize = referenceViewSize
        }
        
        self.referencePaddingAmount = referencePaddingAmount
        
        if referenceFontSize == .zero {
            self.referenceFontSize = 32 // Fallback to prevent divide-by-zero errors
        } else {
            self.referenceFontSize = referenceFontSize
        }
    }
    
    func getEquivalentPadding(for edges: Edge.Set, padding: CGFloat?) -> EdgeInsets {
        guard self.referenceViewSize != .zero,
              self.referenceViewSize.width != .zero,
              self.referenceViewSize.height != .zero
        else {
            return EdgeInsets(
                top: edges.contains(.top) ? padding ?? self.referencePaddingAmount : 0,
                leading: edges.contains(.leading) ? padding ?? self.referencePaddingAmount : 0,
                bottom: edges.contains(.bottom) ? padding ?? self.referencePaddingAmount : 0,
                trailing: edges.contains(.trailing) ? padding ?? self.referencePaddingAmount : 0
            )
        }
        
        let relativeWidth = self.viewSize.width / self.referenceViewSize.width
        let relativeHeight = self.viewSize.height / self.referenceViewSize.height
        
        let horizontalPadding = max(1, abs((padding ?? self.referencePaddingAmount) * relativeWidth))
        let verticalPadding = max(1, abs((padding ?? self.referencePaddingAmount) * relativeHeight))
        
        switch edges {
        case .all:
            return EdgeInsets(top: verticalPadding, leading: horizontalPadding, bottom: verticalPadding, trailing: horizontalPadding)
        case .horizontal:
            return EdgeInsets(top: 0, leading: horizontalPadding, bottom: 0, trailing: horizontalPadding)
        case .vertical:
            return EdgeInsets(top: verticalPadding, leading: 0, bottom: verticalPadding, trailing: 0)
        case .top:
            return EdgeInsets(top: verticalPadding, leading: 0, bottom: 0, trailing: 0)
        case .bottom:
            return EdgeInsets(top: 0, leading: 0, bottom: verticalPadding, trailing: 0)
        case .leading:
            return EdgeInsets(top: 0, leading: horizontalPadding, bottom: 0, trailing: 0)
        case .trailing:
            return EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: horizontalPadding)
        default:
            return EdgeInsets()
        }
    }
    
    func getEquivalentFontSize(for font: Font?, for size: CGFloat?) -> Font {
        guard self.referenceViewSize != .zero,
              self.referenceViewSize.width != .zero,
              self.referenceViewSize.height != .zero,
              self.referenceFontSize != .zero
        else {
            return font ?? .system(size: size ?? self.referenceFontSize)
        }
        
        let relativeWidth = self.viewSize.width / self.referenceViewSize.width
        let relativeHeight = self.viewSize.height / self.referenceViewSize.height
        
        let scaleFactor = max(1 / self.referenceFontSize, min(relativeWidth, relativeHeight))
        
        if let font = font {
            switch font {
            case .largeTitle:
                return Font.system(size: self.referenceFontSize * 2.000 * scaleFactor)
            case .title:
                return Font.system(size: self.referenceFontSize * 1.500 * scaleFactor)
            case .title2:
                return Font.system(size: self.referenceFontSize * 1.250 * scaleFactor)
            case .title3:
                return Font.system(size: self.referenceFontSize * 1.125 * scaleFactor)
            case .body:
                return Font.system(size: self.referenceFontSize * 1.000 * scaleFactor)
            case .caption:
                return Font.system(size: self.referenceFontSize * 0.875 * scaleFactor)
            case .caption2:
                return Font.system(size: self.referenceFontSize * 0.750 * scaleFactor)
            default:
                return Font.system(size: self.referenceFontSize * 1.000 * scaleFactor)
            }
        } else if let size = size {
            return Font.system(size: size * scaleFactor)
        } else {
            return .system(size: self.referenceFontSize)
        }
    }
    
    func getEquivalentValue(_ value: CGFloat) -> CGFloat {
        guard self.referenceViewSize != .zero, self.referenceViewSize.width != .zero, self.referenceViewSize.height != .zero else { return value }
        
        let relativeWidth = self.viewSize.width / self.referenceViewSize.width
        let relativeHeight = self.viewSize.height / self.referenceViewSize.height
        
        return max(1, min(relativeWidth * value, relativeHeight * value))
    }
}

struct DynamicPaddingModifier: ViewModifier {
    
    @EnvironmentObject var dynamicSizingViewModel: DynamicSizingViewModel
    
    let edges: Edge.Set
    let padding: CGFloat?
    
    func body(content: Content) -> some View {
        content
            .padding(dynamicSizingViewModel.getEquivalentPadding(for: edges, padding: padding))
    }
}

struct DynamicFontModifier: ViewModifier {
    
    @EnvironmentObject var dynamicSizingViewModel: DynamicSizingViewModel
    
    let font: Font?
    let size: CGFloat?
    
    func body(content: Content) -> some View {
        content
            .font(dynamicSizingViewModel.getEquivalentFontSize(for: font, for: size))
    }
}

extension View {
    func dynamicPadding() -> some View {
        self.modifier(DynamicPaddingModifier(edges: [.all], padding: nil))
    }
    
    func dynamicPadding(_ padding: CGFloat?) -> some View {
        self.modifier(DynamicPaddingModifier(edges: [.all], padding: padding))
    }
    
    func dynamicPadding(_ edges: Edge.Set) -> some View {
        self.modifier(DynamicPaddingModifier(edges: edges, padding: nil))
    }
    
    func dynamicPadding(_ edges: Edge.Set, _ padding: CGFloat?) -> some View {
        self.modifier(DynamicPaddingModifier(edges: edges, padding: padding))
    }
    
    func dynamicFont(_ font: Font = .body) -> some View {
        self.modifier(DynamicFontModifier(font: font, size: nil))
    }
    
    func dynamicFont(_ size: CGFloat?) -> some View {
        self.modifier(DynamicFontModifier(font: nil, size: size))
    }
}

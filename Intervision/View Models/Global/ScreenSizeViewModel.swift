//
//  ScreenSizeViewModel.swift
//  Intervision
//
//  Created by Reuben on 02/05/2024.
//

import Foundation
import SwiftUI

class ScreenSizeViewModel: ObservableObject {
    
    @Published var screenSize: CGSize = .zero
    
    func equivalentPadding(edges: Edge.Set, padding: CGFloat) -> EdgeInsets {
        let referenceScreenSize = CGSize(width: 2560, height: 1440)
        
        let relativeWidth = self.screenSize.width / referenceScreenSize.width
        let relativeHeight = self.screenSize.height / referenceScreenSize.height
        
        let horizontalPadding = max(1, abs(padding * relativeWidth))
        let verticalPadding = max(1, abs(padding * relativeHeight))
        
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
    
    func equivalentFont(font: Font) -> CGFloat {
        let referenceScreenSize = CGSize(width: 2560, height: 1440)
        let referenceFontSize: CGFloat = 32
        
        let relativeWidth = self.screenSize.width / referenceScreenSize.width
        let relativeHeight = self.screenSize.height / referenceScreenSize.height
        
        let scaleFactor = max(1 / referenceFontSize, min(relativeWidth, relativeHeight))
        
        switch font {
        case .largeTitle:
            return referenceFontSize * 2.0 * scaleFactor
        case .title:
            return referenceFontSize * 1.5 * scaleFactor
        case .title2:
            return referenceFontSize * 1.25 * scaleFactor
        case .title3:
            return referenceFontSize * 1.125 * scaleFactor
        case .body:
            return referenceFontSize * scaleFactor
        case .caption:
            return referenceFontSize * 0.875 * scaleFactor
        case .caption2:
            return referenceFontSize * 0.75 * scaleFactor
        default:
            return referenceFontSize * scaleFactor
        }
    }
    
    func getEquivalentValue(_ value: CGFloat) -> CGFloat {
        let referenceScreenSize = CGSize(width: 2560, height: 1440)
        
        let relativeWidth = self.screenSize.width / referenceScreenSize.width
        let relativeHeight = self.screenSize.height / referenceScreenSize.height
        
        return max(1, min(relativeWidth * value, relativeHeight * value))
    }
}

struct EquivalentPaddingModifier: ViewModifier {
    
    @EnvironmentObject var screenSizeViewModel: ScreenSizeViewModel
    
    let edges: Edge.Set
    let padding: CGFloat
    
    func body(content: Content) -> some View {
        content.padding(screenSizeViewModel.equivalentPadding(edges: edges, padding: padding))
    }
}

struct EquivalentFontModifier: ViewModifier {
    
    @EnvironmentObject var screenSizeViewModel: ScreenSizeViewModel
    
    let font: Font
    
    func body(content: Content) -> some View {
        content.font(.system(size: screenSizeViewModel.equivalentFont(font: font)))
    }
}

extension View {
    func equivalentPadding(_ padding: CGFloat = 8) -> some View {
        self.modifier(EquivalentPaddingModifier(edges: [.all], padding: padding))
    }
    
    func equivalentPadding(_ edges: Edge.Set = [.all], _ padding: CGFloat = 8) -> some View {
        self.modifier(EquivalentPaddingModifier(edges: edges, padding: padding))
    }
    
    func equivalentFont(_ font: Font = .body) -> some View {
        self.modifier(EquivalentFontModifier(font: font))
    }
}
